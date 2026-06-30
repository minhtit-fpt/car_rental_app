import { z } from "zod";
import { AppError } from "@/lib/errors/app-error";
import { adminRepository } from "@/lib/repositories/admin.repository";
import {
  llmClient,
  parseJsonFromText,
  type ChatTurn,
} from "@/lib/ai/llm.client";

// Phase 4 — trợ lý xử lý tranh chấp. AI ADVISORY: tổng hợp ngữ cảnh → tóm tắt +
// quy lỗi + đề xuất. Mọi thay đổi tiền/trạng thái vẫn do admin bấm nút.
// NEO: mức hoàn tiền tính trong code (min(estimatedCost, đã trả)), KHÔNG để
// LLM tự sinh số. Lazy-generate (không cache); LM Studio offline → ai = null.

export interface DisputeFacts {
  disputeTitle: string;
  disputeDescription: string | null;
  raisedByRole: "renter" | "owner" | "other";
  bookingStatus: string;
  vehicleTitle: string;
  paymentStatus: string | null;
  paidAmount: number | null;
  contractSigned: boolean;
  contractSignedAt: string | null;
  hasCheckin: boolean;
  hasCheckout: boolean;
  damageSummary: string | null;
  estimatedCost: number;
  messageCount: number;
}

export interface DisputeAi {
  summary: string;
  timeline: string[];
  faultParty: "renter" | "owner" | "shared" | "unclear";
  confidence: "low" | "medium" | "high";
  recommendation: string;
}

export interface DisputeAnalysis {
  facts: DisputeFacts;
  // Mức hoàn tiền đề xuất NEO theo dữ liệu cứng, độc lập với LLM (audit-safe).
  anchoredRefund: number;
  ai: DisputeAi | null;
  aiError: string | null;
}

const aiSchema = z.object({
  summary: z.string().default(""),
  timeline: z.array(z.string()).default([]),
  faultParty: z.enum(["renter", "owner", "shared", "unclear"]).default("unclear"),
  confidence: z.enum(["low", "medium", "high"]).default("low"),
  recommendation: z.string().default(""),
});

const SYSTEM_PROMPT = `Bạn là trợ lý xử lý tranh chấp cho nền tảng thuê xe. Bạn
nhận FACTS cứng (đã được hệ thống xác minh) và transcript chat giữa các bên. Chỉ
suy luận DỰA TRÊN facts — KHÔNG bịa số liệu, KHÔNG bịa sự kiện không có trong dữ
liệu. KHÔNG đề xuất số tiền hoàn (hệ thống tự neo theo chi phí hư hỏng).

CHỈ trả về JSON đúng định dạng, KHÔNG kèm giải thích ngoài JSON:
{
  "summary": "tóm tắt ngắn vụ việc bằng tiếng Việt",
  "timeline": ["mốc 1", "mốc 2"],
  "faultParty": "renter|owner|shared|unclear",
  "confidence": "low|medium|high",
  "recommendation": "đề xuất hướng xử lý cho admin (text)"
}`;

function partyRole(
  raisedById: string,
  renterId: string,
  ownerId: string,
): DisputeFacts["raisedByRole"] {
  if (raisedById === renterId) return "renter";
  if (raisedById === ownerId) return "owner";
  return "other";
}

function buildFactsBlock(f: DisputeFacts): string {
  return [
    `Tiêu đề: ${f.disputeTitle}`,
    `Mô tả: ${f.disputeDescription ?? "(không có)"}`,
    `Bên khiếu nại: ${f.raisedByRole}`,
    `Xe: ${f.vehicleTitle}`,
    `Trạng thái đơn: ${f.bookingStatus}`,
    `Thanh toán: ${f.paymentStatus ?? "chưa có"}${
      f.paidAmount != null ? ` (${f.paidAmount}đ)` : ""
    }`,
    `Hợp đồng đã ký: ${f.contractSigned ? `có (${f.contractSignedAt})` : "chưa"}`,
    `Ảnh nhận xe: ${f.hasCheckin ? "có" : "không"} · Ảnh trả xe: ${
      f.hasCheckout ? "có" : "không"
    }`,
    `Báo cáo hư hỏng: ${f.damageSummary ?? "không có"}`,
    `Chi phí hư hỏng ước tính: ${f.estimatedCost}đ`,
  ].join("\n");
}

export const disputeAnalysisService = {
  async analyze(disputeId: string): Promise<DisputeAnalysis> {
    const d = await adminRepository.findDisputeContext(disputeId);
    if (!d || !d.booking) {
      throw new AppError(404, "DISPUTE_NOT_FOUND", "Không tìm thấy tranh chấp");
    }
    const b = d.booking;
    const phases = new Set(b.inspections.map((i) => i.phase));
    const paidAmount = b.payment?.amount?.toNumber() ?? null;
    const estimatedCost = b.damageReport?.estimatedCost ?? 0;

    const facts: DisputeFacts = {
      disputeTitle: d.title,
      disputeDescription: d.description,
      raisedByRole: partyRole(d.raisedById, b.renterId, b.vehicle.ownerId),
      bookingStatus: b.status,
      vehicleTitle: b.vehicle.title,
      paymentStatus: b.payment?.status ?? null,
      paidAmount,
      contractSigned: b.contract?.signedAt != null,
      contractSignedAt: b.contract?.signedAt?.toISOString() ?? null,
      hasCheckin: phases.has("CHECKIN"),
      hasCheckout: phases.has("CHECKOUT"),
      damageSummary: b.damageReport?.summary ?? null,
      estimatedCost,
      messageCount: b.conversation?.messages.length ?? 0,
    };

    // NEO: chỉ hoàn được khi đã trả; trần là số đã trả.
    const anchoredRefund =
      paidAmount != null ? Math.min(estimatedCost, paidAmount) : 0;

    const transcript = (b.conversation?.messages ?? [])
      .map((m) => {
        const who =
          m.senderId === b.renterId
            ? "Người thuê"
            : m.senderId === b.vehicle.ownerId
              ? "Chủ xe"
              : "Khác";
        return `[${who}] ${m.body}`;
      })
      .join("\n");

    const messages: ChatTurn[] = [
      { role: "system", content: SYSTEM_PROMPT },
      {
        role: "user",
        content: `FACTS:\n${buildFactsBlock(facts)}\n\nTRANSCRIPT CHAT:\n${
          transcript || "(không có tin nhắn)"
        }`,
      },
    ];

    try {
      const raw = await llmClient.chat(messages);
      const ai = aiSchema.parse(parseJsonFromText(raw));
      return { facts, anchoredRefund, ai, aiError: null };
    } catch (error) {
      // Offline / lỗi định dạng → vẫn trả fact cứng + neo để admin tự quyết.
      const aiError =
        error instanceof AppError
          ? error.message
          : "Chưa phân tích được bằng AI";
      return { facts, anchoredRefund, ai: null, aiError };
    }
  },
};
