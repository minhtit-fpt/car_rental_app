import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/services/admin.service", () => ({
  adminService: { getMetrics: vi.fn() },
}));

vi.mock("@/lib/ai/llm.client", async (importActual) => {
  const actual = await importActual<typeof import("@/lib/ai/llm.client")>();
  return { ...actual, llmClient: { chat: vi.fn() } };
});

import { analyticsService } from "@/lib/services/analytics.service";
import { adminService } from "@/lib/services/admin.service";
import { llmClient } from "@/lib/ai/llm.client";
import { AppError } from "@/lib/errors/app-error";

const METRICS = {
  kpi: {
    totalUsers: 10,
    totalVehicles: 5,
    availableVehicles: 4,
    electricVehicles: 2,
    totalBookings: 8,
    completionRate: 0.75,
    cancellationRate: 0.125,
    avgRating: 4.32,
  },
  bookingsByStatus: [{ status: "COMPLETED", count: 6 }],
  paymentsByMethod: [{ method: "VNPAY", total: 3_000_000 }],
  vehiclesByType: [{ type: "CAR", count: 5, electric: 2 }],
  topVehicles: [{ id: "v1", title: "VF8", revenue: 2_000_000, trips: 3 }],
  recentBookings: [
    { id: "b1", vehicleTitle: "VF8", status: "PAID", totalPrice: 500_000, createdAt: "x" },
  ],
};

describe("analyticsService.ask", () => {
  beforeEach(() => vi.clearAllMocks());

  it("ánh xạ câu hỏi → template + format câu trả lời", async () => {
    vi.mocked(llmClient.chat).mockResolvedValue('{"key":"revenue_by_method"}');
    vi.mocked(adminService.getMetrics).mockResolvedValue(METRICS as never);

    const r = await analyticsService.ask("doanh thu bao nhiêu?");
    expect(r.templateKey).toBe("revenue_by_method");
    expect(r.answer).toContain("3.000.000đ");
    expect(adminService.getMetrics).toHaveBeenCalledOnce();
  });

  it("template không khớp → không hỗ trợ, không chạy metrics", async () => {
    vi.mocked(llmClient.chat).mockResolvedValue('{"key":"none"}');

    const r = await analyticsService.ask("thời tiết hôm nay?");
    expect(r.templateKey).toBeNull();
    expect(r.answer).toContain("chưa được hỗ trợ");
    expect(adminService.getMetrics).not.toHaveBeenCalled();
  });

  it("LM Studio offline → thông báo offline", async () => {
    vi.mocked(llmClient.chat).mockRejectedValue(
      new AppError(503, "LLM_UNAVAILABLE", "offline"),
    );

    const r = await analyticsService.ask("doanh thu?");
    expect(r.templateKey).toBeNull();
    expect(r.answer).toContain("offline");
  });
});
