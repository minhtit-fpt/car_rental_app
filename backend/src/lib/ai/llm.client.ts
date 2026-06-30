import { AppError } from "@/lib/errors/app-error";

// Client gọi LLM text (qua LM Studio, OpenAI-compatible) — dùng chung cho trợ lý
// tranh chấp (Phase 4), NL-analytics (Phase 5a) và lời giải thích rủi ro (5b).
// Tách riêng SDK: chỉ fetch JSON. Offline → AppError 503 để service fallback.

const BASE_URL = process.env.LM_STUDIO_BASE_URL ?? "http://localhost:1234/v1";
// Model text riêng; fallback về VLM model (cùng họ Qwen, chạy text được) để
// không phải cấu hình thêm khi chỉ có 1 model nạp trong LM Studio.
const TEXT_MODEL =
  process.env.LLM_MODEL ?? process.env.VLM_MODEL ?? "qwen2.5-vl-7b-instruct";
const REQUEST_TIMEOUT_MS = 120_000;

export interface ChatTurn {
  role: "system" | "user" | "assistant";
  content: string;
}

export const llmClient = {
  async chat(
    messages: ChatTurn[],
    opts?: { temperature?: number },
  ): Promise<string> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
    let res: Response;
    try {
      res = await fetch(`${BASE_URL}/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        signal: controller.signal,
        body: JSON.stringify({
          model: TEXT_MODEL,
          temperature: opts?.temperature ?? 0.2,
          messages,
        }),
      });
    } catch {
      throw new AppError(503, "LLM_UNAVAILABLE", "Không kết nối được dịch vụ AI");
    } finally {
      clearTimeout(timeout);
    }
    if (!res.ok) {
      throw new AppError(502, "LLM_BAD_RESPONSE", "Dịch vụ AI trả về lỗi");
    }
    const json = (await res.json()) as {
      choices?: Array<{ message?: { content?: string } }>;
    };
    const content = json.choices?.[0]?.message?.content;
    if (!content) {
      throw new AppError(
        502,
        "LLM_BAD_RESPONSE",
        "Dịch vụ AI không trả về nội dung",
      );
    }
    return content;
  },
};

// Bóc JSON object đầu tiên ra khỏi text LLM (bỏ code fence ```json). Caller tự
// validate bằng zod. Lỗi định dạng → AppError 502.
export function parseJsonFromText(content: string): unknown {
  const stripped = content
    .replace(/```(?:json)?/gi, "")
    .replace(/```/g, "")
    .trim();
  const start = stripped.indexOf("{");
  const end = stripped.lastIndexOf("}");
  if (start === -1 || end === -1 || end < start) {
    throw new AppError(502, "LLM_BAD_RESPONSE", "AI không trả về JSON hợp lệ");
  }
  try {
    return JSON.parse(stripped.slice(start, end + 1));
  } catch {
    throw new AppError(502, "LLM_BAD_RESPONSE", "AI không trả về JSON hợp lệ");
  }
}
