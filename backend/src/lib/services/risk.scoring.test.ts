import { describe, expect, it } from "vitest";
import { scoreRisk, type RiskFacts } from "@/lib/services/risk.scoring";

const base: RiskFacts = {
  accountAgeDays: 365,
  totalBookings: 0,
  cancelledBookings: 0,
  completedBookings: 0,
  maxBookingValue: 0,
  failedPayments: 0,
  selfRentals: 0,
  ownedBookings: 0,
  ownedCompleted: 0,
  roles: ["RENTER"],
};

describe("scoreRisk", () => {
  it("không rule nào → LOW, score 0", () => {
    const r = scoreRisk(base);
    expect(r).toEqual({ score: 0, tier: "LOW", reasons: [] });
  });

  it("tài khoản mới + đơn giá trị cao → +2 MEDIUM", () => {
    const r = scoreRisk({
      ...base,
      accountAgeDays: 2,
      maxBookingValue: 3_000_000,
    });
    expect(r.tier).toBe("MEDIUM");
    expect(r.reasons.map((x) => x.code)).toContain("NEW_ACCOUNT_HIGH_VALUE");
  });

  it("tài khoản cũ dù đơn cao → không cờ", () => {
    const r = scoreRisk({
      ...base,
      accountAgeDays: 30,
      maxBookingValue: 3_000_000,
    });
    expect(r.score).toBe(0);
  });

  it("tự thuê xe → +3, đủ MEDIUM", () => {
    const r = scoreRisk({ ...base, selfRentals: 1 });
    expect(r.score).toBe(3);
    expect(r.tier).toBe("MEDIUM");
    expect(r.reasons[0].code).toBe("SELF_RENTAL");
  });

  it("tỉ lệ huỷ cao cần đủ số đơn tối thiểu", () => {
    const few = scoreRisk({
      ...base,
      totalBookings: 2,
      cancelledBookings: 2,
    });
    expect(few.score).toBe(0); // dưới ngưỡng 5 đơn

    const many = scoreRisk({
      ...base,
      totalBookings: 6,
      cancelledBookings: 3,
    });
    expect(many.reasons.map((x) => x.code)).toContain("HIGH_CANCELLATION");
  });

  it("nhiều rule cộng dồn → HIGH", () => {
    const r = scoreRisk({
      ...base,
      selfRentals: 1, // +3
      failedPayments: 3, // +2
    });
    expect(r.score).toBe(5);
    expect(r.tier).toBe("HIGH");
  });

  it("chủ xe nhiều đơn nhưng 0 hoàn tất → +1", () => {
    const r = scoreRisk({
      ...base,
      roles: ["OWNER"],
      ownedBookings: 6,
      ownedCompleted: 0,
    });
    expect(r.reasons.map((x) => x.code)).toContain("OWNER_NO_COMPLETION");
  });
});
