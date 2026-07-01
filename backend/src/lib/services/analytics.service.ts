import { AppError } from "@/lib/errors/app-error";
import { llmClient } from "@/lib/ai/llm.client";

// NL-analytics (admin). Trước đây chỉ khớp 1 trong 8 template = đúng các widget đã
// hiện trên dashboard → không hỏi sâu được. Nay ủy quyền cho trợ lý tool-calling ở
// ai-service (prompt + bộ tool admin riêng): LLM tự gọi API admin đọc số liệu thực
// để trả lời câu hỏi bất kỳ. ai-service offline → fallback thông báo, không ném lỗi.

export interface AnalyticsAnswer {
  answer: string;
  // Tên các tool admin mà LLM đã gọi để lấy số liệu (minh bạch nguồn dữ liệu).
  toolsUsed: string[];
}

export const analyticsService = {
  async ask(question: string, token: string): Promise<AnalyticsAnswer> {
    try {
      return await llmClient.adminChat(question, token);
    } catch (error) {
      if (error instanceof AppError && error.status === 503) {
        return {
          answer: "Dịch vụ AI đang offline, chưa thể phân tích câu hỏi.",
          toolsUsed: [],
        };
      }
      throw error;
    }
  },
};
