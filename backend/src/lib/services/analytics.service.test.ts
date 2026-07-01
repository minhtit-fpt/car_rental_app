import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/ai/llm.client", async (importActual) => {
  const actual = await importActual<typeof import("@/lib/ai/llm.client")>();
  return { ...actual, llmClient: { adminChat: vi.fn() } };
});

import { analyticsService } from "@/lib/services/analytics.service";
import { llmClient } from "@/lib/ai/llm.client";
import { AppError } from "@/lib/errors/app-error";

describe("analyticsService.ask", () => {
  beforeEach(() => vi.clearAllMocks());

  it("ủy quyền cho trợ lý tool-calling + forward token", async () => {
    vi.mocked(llmClient.adminChat).mockResolvedValue({
      answer: "Tổng doanh thu 3.000.000đ.",
      toolsUsed: ["get_metrics"],
    });

    const r = await analyticsService.ask("doanh thu bao nhiêu?", "tok");
    expect(r.answer).toContain("3.000.000đ");
    expect(r.toolsUsed).toEqual(["get_metrics"]);
    expect(llmClient.adminChat).toHaveBeenCalledWith("doanh thu bao nhiêu?", "tok");
  });

  it("LM Studio offline → thông báo offline, không ném lỗi", async () => {
    vi.mocked(llmClient.adminChat).mockRejectedValue(
      new AppError(503, "LLM_UNAVAILABLE", "offline"),
    );

    const r = await analyticsService.ask("doanh thu?", "tok");
    expect(r.answer).toContain("offline");
    expect(r.toolsUsed).toEqual([]);
  });

  it("lỗi khác (không phải 503) → ném ra để caller xử lý", async () => {
    vi.mocked(llmClient.adminChat).mockRejectedValue(
      new AppError(502, "LLM_BAD_RESPONSE", "lỗi"),
    );

    await expect(analyticsService.ask("doanh thu?", "tok")).rejects.toThrow(
      "lỗi",
    );
  });
});
