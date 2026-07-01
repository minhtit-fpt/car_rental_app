import { AppError } from "@/lib/errors/app-error";

// Client gọi tính năng LLM text qua **ai-service** (FastAPI) — nơi tập trung MỌI
// điểm cắm LM Studio + cấu hình model (giống chatbot RAG gọi ai-service, không
// gọi thẳng LM Studio). Dùng chung cho trợ lý tranh chấp (Phase 4), NL-analytics
// (5a) và giải thích rủi ro (5b). ai-service offline → AppError 503 để fallback.

const AI_SERVICE_URL = process.env.AI_SERVICE_URL ?? "http://localhost:8000";
const REQUEST_TIMEOUT_MS = 120_000;

export interface ChatTurn {
  role: "system" | "user" | "assistant";
  content: string;
}

export const llmClient = {
  async chat(messages: ChatTurn[]): Promise<string> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
    let res: Response;
    try {
      res = await fetch(`${AI_SERVICE_URL}/admin/complete`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        signal: controller.signal,
        body: JSON.stringify({ messages }),
      });
    } catch {
      throw new AppError(503, "LLM_UNAVAILABLE", "Không kết nối được dịch vụ AI");
    } finally {
      clearTimeout(timeout);
    }
    // ai-service trả 503 khi LM Studio offline → giữ nguyên để service fallback.
    if (res.status === 503) {
      throw new AppError(503, "LLM_UNAVAILABLE", "Dịch vụ AI đang offline");
    }
    if (!res.ok) {
      throw new AppError(502, "LLM_BAD_RESPONSE", "Dịch vụ AI trả về lỗi");
    }
    const json = (await res.json()) as { data?: { content?: string } };
    const content = json.data?.content;
    if (!content) {
      throw new AppError(
        502,
        "LLM_BAD_RESPONSE",
        "Dịch vụ AI không trả về nội dung",
      );
    }
    return content;
  },

  // Hỏi-đáp phân tích admin: ai-service chạy tool-calling vào API admin nên PHẢI
  // forward token admin của phiên. Trả {answer, toolsUsed}. 503 → service fallback.
  async adminChat(
    message: string,
    token: string,
  ): Promise<{ answer: string; toolsUsed: string[] }> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
    let res: Response;
    try {
      res = await fetch(`${AI_SERVICE_URL}/admin/chat`, {
        method: "POST",
        headers: {
          "content-type": "application/json",
          authorization: `Bearer ${token}`,
        },
        signal: controller.signal,
        body: JSON.stringify({ message }),
      });
    } catch {
      throw new AppError(503, "LLM_UNAVAILABLE", "Không kết nối được dịch vụ AI");
    } finally {
      clearTimeout(timeout);
    }
    if (res.status === 503) {
      throw new AppError(503, "LLM_UNAVAILABLE", "Dịch vụ AI đang offline");
    }
    if (!res.ok) {
      throw new AppError(502, "LLM_BAD_RESPONSE", "Dịch vụ AI trả về lỗi");
    }
    const json = (await res.json()) as {
      data?: { answer?: string; toolsUsed?: string[] };
    };
    const answer = json.data?.answer;
    if (!answer) {
      throw new AppError(
        502,
        "LLM_BAD_RESPONSE",
        "Dịch vụ AI không trả về nội dung",
      );
    }
    return { answer, toolsUsed: json.data?.toolsUsed ?? [] };
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
