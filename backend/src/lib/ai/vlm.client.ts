import { z } from "zod";
import { AppError } from "@/lib/errors/app-error";

// Client gọi VLM (Qwen2.5-VL) qua LM Studio (OpenAI-compatible) để so ảnh xe
// trước/sau và liệt kê hư hỏng MỚI. Giữ tách biệt SDK: chỉ fetch JSON.

const BASE_URL = process.env.LM_STUDIO_BASE_URL ?? "http://localhost:1234/v1";
const VLM_MODEL = process.env.VLM_MODEL ?? "qwen2.5-vl-7b-instruct";
const REQUEST_TIMEOUT_MS = 120_000;

export const damageSeveritySchema = z.enum(["minor", "moderate", "severe"]);

const damageItemSchema = z.object({
  label: z.string().min(1),
  severity: damageSeveritySchema,
  description: z.string().default(""),
});

export const damageAnalysisSchema = z.object({
  summary: z.string().default(""),
  items: z.array(damageItemSchema),
  estimatedCost: z.number().int().nonnegative().default(0),
});

export type DamageAnalysis = z.infer<typeof damageAnalysisSchema>;

export interface InspectionImage {
  contentType: string;
  bytes: Buffer;
}

const JSON_FORMAT = `CHỈ trả về JSON đúng định dạng sau, KHÔNG kèm giải thích ngoài JSON:
{
  "summary": "tóm tắt ngắn bằng tiếng Việt",
  "items": [
    { "label": "loại hư hỏng", "severity": "minor|moderate|severe", "description": "vị trí + mô tả" }
  ],
  "estimatedCost": <số tiền bồi thường gợi ý bằng VND, số nguyên>
}`;

// So ảnh trước/sau → chỉ hư hỏng MỚI (dùng tính bồi thường).
const DIFF_SYSTEM_PROMPT = `Bạn là chuyên gia giám định hư hỏng xe cho thuê. Bạn nhận
hai nhóm ảnh: nhóm BEFORE (lúc giao xe) và nhóm AFTER (lúc trả xe). Chỉ liệt kê
hư hỏng MỚI xuất hiện ở AFTER mà không có ở BEFORE (trầy xước, móp, vỡ kính, bể
đèn, thủng lốp...). Bỏ qua bụi bẩn và khác biệt do ánh sáng/góc chụp.

${JSON_FORMAT}
Nếu không có hư hỏng mới: items là [] và estimatedCost là 0.`;

// Soi 1 nhóm ảnh tại 1 thời điểm → MỌI hư hỏng nhìn thấy (tình trạng xe lúc đó).
const DETECT_SYSTEM_PROMPT = `Bạn là chuyên gia giám định xe cho thuê. Bạn nhận một
nhóm ảnh chụp xe tại thời điểm GIAO hoặc TRẢ xe. Hãy liệt kê MỌI hư hỏng nhìn
thấy được trên xe (trầy xước, móp, vỡ kính, bể đèn, thủng lốp...). Bỏ qua bụi bẩn
và khác biệt do ánh sáng/góc chụp. Trường estimatedCost luôn để 0 ở bước này.

${JSON_FORMAT}
Nếu xe không có hư hỏng: items là [] và estimatedCost là 0.`;

function toDataUri(image: InspectionImage): string {
  return `data:${image.contentType};base64,${image.bytes.toString("base64")}`;
}

// Tách JSON ra khỏi text trả về của LLM: bỏ code fence ```json, lấy object {...}
// đầu tiên → parse → validate. Lỗi định dạng → AppError 502.
export function parseDamageAnalysis(content: string): DamageAnalysis {
  const withoutFence = content
    .replace(/```(?:json)?/gi, "")
    .replace(/```/g, "")
    .trim();
  const start = withoutFence.indexOf("{");
  const end = withoutFence.lastIndexOf("}");
  if (start === -1 || end === -1 || end < start) {
    throw new AppError(502, "VLM_BAD_RESPONSE", "VLM không trả về JSON hợp lệ");
  }
  let raw: unknown;
  try {
    raw = JSON.parse(withoutFence.slice(start, end + 1));
  } catch {
    throw new AppError(502, "VLM_BAD_RESPONSE", "VLM không trả về JSON hợp lệ");
  }
  const parsed = damageAnalysisSchema.safeParse(raw);
  if (!parsed.success) {
    throw new AppError(502, "VLM_BAD_RESPONSE", "VLM trả về JSON sai cấu trúc");
  }
  return parsed.data;
}

function imageParts(images: InspectionImage[]): Array<Record<string, unknown>> {
  return images.map((img) => ({
    type: "image_url",
    image_url: { url: toDataUri(img) },
  }));
}

// Gọi VLM với 1 system prompt + nội dung user (text + ảnh) → parse JSON hư hỏng.
async function callVlm(
  systemPrompt: string,
  content: Array<Record<string, unknown>>,
): Promise<DamageAnalysis> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  let res: Response;
  try {
    res = await fetch(`${BASE_URL}/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      signal: controller.signal,
      body: JSON.stringify({
        model: VLM_MODEL,
        temperature: 0.2,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content },
        ],
      }),
    });
  } catch (error) {
    throw new AppError(
      503,
      "VLM_UNAVAILABLE",
      "Không kết nối được dịch vụ AI nhận diện hư hỏng",
    );
  } finally {
    clearTimeout(timeout);
  }

  if (!res.ok) {
    throw new AppError(502, "VLM_ERROR", `VLM trả về lỗi (HTTP ${res.status})`);
  }

  const data = (await res.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const text = data.choices?.[0]?.message?.content;
  if (!text) {
    throw new AppError(502, "VLM_BAD_RESPONSE", "VLM trả về rỗng");
  }
  return parseDamageAnalysis(text);
}

export const vlmClient = {
  // So ảnh BEFORE ↔ AFTER → chỉ hư hỏng MỚI + chi phí bồi thường gợi ý.
  analyzeDamage(
    before: InspectionImage[],
    after: InspectionImage[],
  ): Promise<DamageAnalysis> {
    return callVlm(DIFF_SYSTEM_PROMPT, [
      { type: "text", text: "Nhóm ảnh BEFORE (lúc giao xe):" },
      ...imageParts(before),
      { type: "text", text: "Nhóm ảnh AFTER (lúc trả xe):" },
      ...imageParts(after),
    ]);
  },

  // Soi 1 nhóm ảnh (lúc nhận HOẶC trả) → mọi hư hỏng đang nhìn thấy.
  detectDamage(images: InspectionImage[]): Promise<DamageAnalysis> {
    return callVlm(DETECT_SYSTEM_PROMPT, [
      { type: "text", text: "Nhóm ảnh chụp xe:" },
      ...imageParts(images),
    ]);
  },
};
