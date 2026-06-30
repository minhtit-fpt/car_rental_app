import type { UserRole } from "@prisma/client";

// Rule engine chấm điểm rủi ro gian lận — EXPLAINABLE, KHÔNG dùng LLM. Mỗi rule
// kích hoạt cộng `weight` vào điểm và để lại một `reason` (chính là lời giải
// thích "vì sao bị cờ"). Điểm → tier. Giữ thuần để unit-test dễ.

export type RiskTier = "LOW" | "MEDIUM" | "HIGH";

export interface RiskFacts {
  accountAgeDays: number;
  totalBookings: number;
  cancelledBookings: number;
  completedBookings: number;
  maxBookingValue: number;
  failedPayments: number;
  selfRentals: number;
  ownedBookings: number;
  ownedCompleted: number;
  roles: UserRole[];
}

export interface RiskReason {
  code: string;
  label: string;
}

export interface RiskResult {
  score: number;
  tier: RiskTier;
  reasons: RiskReason[];
}

// Ngưỡng — tách hằng số để dễ chỉnh, không rải magic number.
const HIGH_VALUE_VND = 2_000_000;
const NEW_ACCOUNT_DAYS = 7;
const MIN_BOOKINGS_FOR_CANCEL_RATE = 5;
const HIGH_CANCEL_RATE = 0.5;
const MIN_FAILED_PAYMENTS = 3;
const MIN_OWNED_FOR_NO_COMPLETION = 5;

const TIER_MEDIUM_MIN = 2;
const TIER_HIGH_MIN = 5;

export function scoreRisk(f: RiskFacts): RiskResult {
  const reasons: RiskReason[] = [];
  let score = 0;

  const add = (weight: number, code: string, label: string): void => {
    score += weight;
    reasons.push({ code, label });
  };

  if (f.accountAgeDays < NEW_ACCOUNT_DAYS && f.maxBookingValue >= HIGH_VALUE_VND) {
    add(2, "NEW_ACCOUNT_HIGH_VALUE", "Tài khoản mới đặt đơn giá trị cao");
  }

  if (f.selfRentals > 0) {
    add(3, "SELF_RENTAL", "Tự thuê xe của chính mình");
  }

  if (
    f.totalBookings >= MIN_BOOKINGS_FOR_CANCEL_RATE &&
    f.cancelledBookings / f.totalBookings >= HIGH_CANCEL_RATE
  ) {
    add(2, "HIGH_CANCELLATION", "Tỉ lệ huỷ đơn bất thường");
  }

  if (f.failedPayments >= MIN_FAILED_PAYMENTS) {
    add(2, "REPEATED_PAYMENT_FAILURE", "Nhiều lần thanh toán thất bại");
  }

  if (
    f.ownedBookings >= MIN_OWNED_FOR_NO_COMPLETION &&
    f.ownedCompleted === 0
  ) {
    add(1, "OWNER_NO_COMPLETION", "Chủ xe nhiều đơn nhưng không chuyến nào hoàn tất");
  }

  const tier: RiskTier =
    score >= TIER_HIGH_MIN ? "HIGH" : score >= TIER_MEDIUM_MIN ? "MEDIUM" : "LOW";

  return { score, tier, reasons };
}

// Người dùng được xếp vào hàng đợi review khi đạt tier MEDIUM trở lên.
export const RISK_FLAG_MIN_SCORE = TIER_MEDIUM_MIN;
