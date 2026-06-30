import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/repositories/admin.repository", () => ({
  adminRepository: { findDisputeContext: vi.fn() },
}));

vi.mock("@/lib/ai/llm.client", async (importActual) => {
  const actual = await importActual<typeof import("@/lib/ai/llm.client")>();
  return { ...actual, llmClient: { chat: vi.fn() } };
});

import { disputeAnalysisService } from "@/lib/services/dispute-analysis.service";
import { adminRepository } from "@/lib/repositories/admin.repository";
import { llmClient } from "@/lib/ai/llm.client";
import { AppError } from "@/lib/errors/app-error";

const dec = (n: number) => ({ toNumber: () => n });

function ctx(over: Record<string, unknown> = {}) {
  return {
    id: "d1",
    title: "Xe trầy xước khi trả",
    description: "Có vết trầy mới ở cửa",
    status: "OPEN",
    priority: "HIGH",
    createdAt: new Date("2026-06-01"),
    raisedById: "owner-1",
    booking: {
      id: "b1",
      status: "COMPLETED",
      startTime: new Date("2026-05-01"),
      endTime: new Date("2026-05-03"),
      totalPrice: dec(1_000_000),
      createdAt: new Date("2026-04-30"),
      renterId: "renter-1",
      vehicle: { title: "VinFast VF8", ownerId: "owner-1" },
      payment: { status: "PAID", amount: dec(1_000_000), paidAt: new Date() },
      contract: { signedAt: new Date("2026-05-01") },
      inspections: [{ phase: "CHECKIN" }, { phase: "CHECKOUT" }],
      damageReport: { summary: "Trầy cửa trái", items: [], estimatedCost: 600_000 },
      conversation: {
        messages: [
          { senderId: "renter-1", body: "Tôi trả xe rồi", sentAt: new Date() },
          { senderId: "owner-1", body: "Xe có vết trầy", sentAt: new Date() },
        ],
      },
      ...((over.booking as object) ?? {}),
    },
    ...over,
  };
}

describe("disputeAnalysisService.analyze", () => {
  beforeEach(() => vi.clearAllMocks());

  it("404 khi không tìm thấy tranh chấp", async () => {
    vi.mocked(adminRepository.findDisputeContext).mockResolvedValue(null as never);
    await expect(disputeAnalysisService.analyze("x")).rejects.toThrow(AppError);
  });

  it("neo hoàn tiền = min(estimatedCost, đã trả) + map facts", async () => {
    vi.mocked(adminRepository.findDisputeContext).mockResolvedValue(ctx() as never);
    vi.mocked(llmClient.chat).mockResolvedValue(
      '{"summary":"ok","timeline":["t1"],"faultParty":"renter","confidence":"high","recommendation":"hoàn một phần"}',
    );

    const r = await disputeAnalysisService.analyze("d1");

    expect(r.anchoredRefund).toBe(600_000); // min(600k, 1tr)
    expect(r.facts.raisedByRole).toBe("owner");
    expect(r.facts.contractSigned).toBe(true);
    expect(r.facts.hasCheckin).toBe(true);
    expect(r.facts.hasCheckout).toBe(true);
    expect(r.facts.messageCount).toBe(2);
    expect(r.ai?.faultParty).toBe("renter");
    expect(r.aiError).toBeNull();
  });

  it("neo bị trần bởi số đã trả", async () => {
    const c = ctx();
    c.booking.payment.amount = dec(400_000);
    c.booking.damageReport.estimatedCost = 600_000;
    vi.mocked(adminRepository.findDisputeContext).mockResolvedValue(c as never);
    vi.mocked(llmClient.chat).mockResolvedValue('{"summary":"x"}');

    const r = await disputeAnalysisService.analyze("d1");
    expect(r.anchoredRefund).toBe(400_000);
  });

  it("LM Studio offline → ai null + aiError, vẫn trả fact + neo", async () => {
    vi.mocked(adminRepository.findDisputeContext).mockResolvedValue(ctx() as never);
    vi.mocked(llmClient.chat).mockRejectedValue(
      new AppError(503, "LLM_UNAVAILABLE", "Không kết nối được dịch vụ AI"),
    );

    const r = await disputeAnalysisService.analyze("d1");
    expect(r.ai).toBeNull();
    expect(r.aiError).toContain("Không kết nối");
    expect(r.anchoredRefund).toBe(600_000);
    expect(r.facts.estimatedCost).toBe(600_000);
  });
});
