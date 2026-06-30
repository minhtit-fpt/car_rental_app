import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  DisputeStatus,
  KycStatus,
  UserRole,
  VehicleApprovalStatus,
} from "@prisma/client";

vi.mock("@/lib/services/notification.service", () => ({
  notificationService: { notify: vi.fn() },
}));

vi.mock("@/lib/repositories/admin.repository", () => ({
  adminRepository: {
    findDisputeById: vi.fn(),
    resolveDispute: vi.fn(),
    findUserById: vi.fn(),
    setUserRoles: vi.fn(),
    countUsers: vi.fn(),
    groupBookingsByStatus: vi.fn(),
    groupPaymentsByMethodPaid: vi.fn(),
    groupVehiclesByTypeElectric: vi.fn(),
    countAvailableVehicles: vi.fn(),
    avgReviewRating: vi.fn(),
    topVehiclesByRevenue: vi.fn(),
    recentBookings: vi.fn(),
    findVehicleOwner: vi.fn(),
    setVehicleApproval: vi.fn(),
    findBookingForRefund: vi.fn(),
    refundPayment: vi.fn(),
    getUserRiskFacts: vi.fn(),
  },
}));

import { adminService } from "@/lib/services/admin.service";
import { AppError } from "@/lib/errors/app-error";
import { adminRepository } from "@/lib/repositories/admin.repository";
import { notificationService } from "@/lib/services/notification.service";

const ADMIN_ID = "admin-1";
const DISPUTE_ID = "dispute-1";

describe("adminService.resolveDispute", () => {
  beforeEach(() => vi.clearAllMocks());

  it("ném 404 khi không tìm thấy tranh chấp", async () => {
    vi.mocked(adminRepository.findDisputeById).mockResolvedValue(null);

    await expect(
      adminService.resolveDispute(ADMIN_ID, DISPUTE_ID, {
        decision: "resolve",
      }),
    ).rejects.toBeInstanceOf(AppError);
  });

  it("resolve → status RESOLVED + báo người tạo", async () => {
    vi.mocked(adminRepository.findDisputeById).mockResolvedValue({
      id: DISPUTE_ID,
      raisedById: "user-9",
      status: DisputeStatus.OPEN,
    });
    vi.mocked(adminRepository.resolveDispute).mockResolvedValue({
      id: DISPUTE_ID,
      status: DisputeStatus.RESOLVED,
    });

    const result = await adminService.resolveDispute(ADMIN_ID, DISPUTE_ID, {
      decision: "resolve",
    });

    expect(result.status).toBe(DisputeStatus.RESOLVED);
    expect(adminRepository.resolveDispute).toHaveBeenCalledWith(
      DISPUTE_ID,
      DisputeStatus.RESOLVED,
      ADMIN_ID,
      undefined,
    );
    expect(notificationService.notify).toHaveBeenCalledWith(
      expect.objectContaining({ userId: "user-9", type: "SYSTEM" }),
    );
  });

  it("reject → status REJECTED, note truyền xuống repo + làm body thông báo", async () => {
    vi.mocked(adminRepository.findDisputeById).mockResolvedValue({
      id: DISPUTE_ID,
      raisedById: "user-9",
      status: DisputeStatus.OPEN,
    });
    vi.mocked(adminRepository.resolveDispute).mockResolvedValue({
      id: DISPUTE_ID,
      status: DisputeStatus.REJECTED,
    });

    await adminService.resolveDispute(ADMIN_ID, DISPUTE_ID, {
      decision: "reject",
      note: "Bằng chứng không đủ",
    });

    expect(adminRepository.resolveDispute).toHaveBeenCalledWith(
      DISPUTE_ID,
      DisputeStatus.REJECTED,
      ADMIN_ID,
      "Bằng chứng không đủ",
    );
    expect(notificationService.notify).toHaveBeenCalledWith(
      expect.objectContaining({ body: "Bằng chứng không đủ" }),
    );
  });
});

describe("adminService.setUserRole", () => {
  const USER_ID = "user-1";

  beforeEach(() => vi.clearAllMocks());

  const mockUpdated = (roles: UserRole[]) =>
    vi.mocked(adminRepository.setUserRoles).mockResolvedValue({
      id: USER_ID,
      phone: "0900000000",
      email: null,
      roles,
      kycStatus: KycStatus.UNVERIFIED,
      createdAt: new Date("2026-01-01T00:00:00.000Z"),
    });

  it("ném 404 khi không tìm thấy user", async () => {
    vi.mocked(adminRepository.findUserById).mockResolvedValue(null);

    await expect(
      adminService.setUserRole(ADMIN_ID, USER_ID, {
        role: UserRole.OWNER,
        action: "add",
      }),
    ).rejects.toBeInstanceOf(AppError);
    expect(adminRepository.setUserRoles).not.toHaveBeenCalled();
  });

  it("ném 409 khi user là ADMIN (user_admin_exclusive)", async () => {
    vi.mocked(adminRepository.findUserById).mockResolvedValue({
      id: USER_ID,
      roles: [UserRole.ADMIN],
    });

    await expect(
      adminService.setUserRole(ADMIN_ID, USER_ID, {
        role: UserRole.OWNER,
        action: "add",
      }),
    ).rejects.toBeInstanceOf(AppError);
    expect(adminRepository.setUserRoles).not.toHaveBeenCalled();
  });

  it("add OWNER → nối vào roles, ghi action USER_ROLE_ADD", async () => {
    vi.mocked(adminRepository.findUserById).mockResolvedValue({
      id: USER_ID,
      roles: [UserRole.RENTER],
    });
    mockUpdated([UserRole.RENTER, UserRole.OWNER]);

    const result = await adminService.setUserRole(ADMIN_ID, USER_ID, {
      role: UserRole.OWNER,
      action: "add",
    });

    expect(result.roles).toEqual([UserRole.RENTER, UserRole.OWNER]);
    expect(adminRepository.setUserRoles).toHaveBeenCalledWith(
      USER_ID,
      [UserRole.RENTER, UserRole.OWNER],
      ADMIN_ID,
      "USER_ROLE_ADD",
      UserRole.OWNER,
    );
  });

  it("remove OWNER → lọc khỏi roles, ghi action USER_ROLE_REMOVE", async () => {
    vi.mocked(adminRepository.findUserById).mockResolvedValue({
      id: USER_ID,
      roles: [UserRole.RENTER, UserRole.OWNER],
    });
    mockUpdated([UserRole.RENTER]);

    await adminService.setUserRole(ADMIN_ID, USER_ID, {
      role: UserRole.OWNER,
      action: "remove",
    });

    expect(adminRepository.setUserRoles).toHaveBeenCalledWith(
      USER_ID,
      [UserRole.RENTER],
      ADMIN_ID,
      "USER_ROLE_REMOVE",
      UserRole.OWNER,
    );
  });

  it("add khi đã có OWNER → idempotent, không nhân đôi", async () => {
    vi.mocked(adminRepository.findUserById).mockResolvedValue({
      id: USER_ID,
      roles: [UserRole.RENTER, UserRole.OWNER],
    });
    mockUpdated([UserRole.RENTER, UserRole.OWNER]);

    await adminService.setUserRole(ADMIN_ID, USER_ID, {
      role: UserRole.OWNER,
      action: "add",
    });

    expect(adminRepository.setUserRoles).toHaveBeenCalledWith(
      USER_ID,
      [UserRole.RENTER, UserRole.OWNER],
      ADMIN_ID,
      "USER_ROLE_ADD",
      UserRole.OWNER,
    );
  });
});

describe("adminService.reviewVehicle", () => {
  const VEHICLE_ID = "veh-1";

  beforeEach(() => vi.clearAllMocks());

  it("ném 404 khi không tìm thấy xe", async () => {
    vi.mocked(adminRepository.findVehicleOwner).mockResolvedValue(null);

    await expect(
      adminService.reviewVehicle(ADMIN_ID, VEHICLE_ID, { decision: "approve" }),
    ).rejects.toBeInstanceOf(AppError);
    expect(adminRepository.setVehicleApproval).not.toHaveBeenCalled();
  });

  it("approve → APPROVED, reason null, báo chủ xe", async () => {
    vi.mocked(adminRepository.findVehicleOwner).mockResolvedValue({
      id: VEHICLE_ID,
      ownerId: "owner-9",
      title: "Tesla",
    });
    vi.mocked(adminRepository.setVehicleApproval).mockResolvedValue({
      id: VEHICLE_ID,
      approvalStatus: VehicleApprovalStatus.APPROVED,
      rejectionReason: null,
    });

    const r = await adminService.reviewVehicle(ADMIN_ID, VEHICLE_ID, {
      decision: "approve",
    });

    expect(r.approvalStatus).toBe(VehicleApprovalStatus.APPROVED);
    expect(adminRepository.setVehicleApproval).toHaveBeenCalledWith(
      VEHICLE_ID,
      VehicleApprovalStatus.APPROVED,
      ADMIN_ID,
      null,
    );
    expect(notificationService.notify).toHaveBeenCalledWith(
      expect.objectContaining({ userId: "owner-9" }),
    );
  });

  it("reject → REJECTED, truyền reason xuống repo + thông báo", async () => {
    vi.mocked(adminRepository.findVehicleOwner).mockResolvedValue({
      id: VEHICLE_ID,
      ownerId: "owner-9",
      title: "Tesla",
    });
    vi.mocked(adminRepository.setVehicleApproval).mockResolvedValue({
      id: VEHICLE_ID,
      approvalStatus: VehicleApprovalStatus.REJECTED,
      rejectionReason: "Ảnh mờ",
    });

    await adminService.reviewVehicle(ADMIN_ID, VEHICLE_ID, {
      decision: "reject",
      rejectionReason: "Ảnh mờ",
    });

    expect(adminRepository.setVehicleApproval).toHaveBeenCalledWith(
      VEHICLE_ID,
      VehicleApprovalStatus.REJECTED,
      ADMIN_ID,
      "Ảnh mờ",
    );
  });
});

describe("adminService.getMetrics", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(adminRepository.countUsers).mockResolvedValue(100);
    vi.mocked(adminRepository.countAvailableVehicles).mockResolvedValue(7);
    vi.mocked(adminRepository.avgReviewRating).mockResolvedValue(4.2);
    vi.mocked(adminRepository.topVehiclesByRevenue).mockResolvedValue([]);
    vi.mocked(adminRepository.recentBookings).mockResolvedValue([]);
    vi.mocked(adminRepository.groupPaymentsByMethodPaid).mockResolvedValue([]);
  });

  it("tính completion/cancellation rate từ bookingsByStatus", async () => {
    // 10 đơn: 5 completed, 2 cancelled, 3 confirmed
    vi.mocked(adminRepository.groupBookingsByStatus).mockResolvedValue([
      { status: "COMPLETED", _count: { _all: 5 } },
      { status: "CANCELLED", _count: { _all: 2 } },
      { status: "CONFIRMED", _count: { _all: 3 } },
    ] as never);
    vi.mocked(adminRepository.groupVehiclesByTypeElectric).mockResolvedValue(
      [] as never,
    );

    const m = await adminService.getMetrics();

    expect(m.kpi.totalBookings).toBe(10);
    expect(m.kpi.completionRate).toBeCloseTo(0.5);
    expect(m.kpi.cancellationRate).toBeCloseTo(0.2);
    expect(m.kpi.totalUsers).toBe(100);
  });

  it("gộp [type, isElectric] → mỗi loại 1 dòng + đếm electric", async () => {
    vi.mocked(adminRepository.groupBookingsByStatus).mockResolvedValue(
      [] as never,
    );
    vi.mocked(adminRepository.groupVehiclesByTypeElectric).mockResolvedValue([
      { type: "CAR", isElectric: true, _count: { _all: 3 } },
      { type: "CAR", isElectric: false, _count: { _all: 4 } },
      { type: "MOTORBIKE", isElectric: false, _count: { _all: 2 } },
    ] as never);

    const m = await adminService.getMetrics();

    const car = m.vehiclesByType.find((v) => v.type === "CAR");
    expect(car).toEqual({ type: "CAR", count: 7, electric: 3 });
    expect(m.kpi.totalVehicles).toBe(9);
    expect(m.kpi.electricVehicles).toBe(3);
    expect(m.kpi.completionRate).toBe(0); // 0 booking → không chia 0
  });
});

describe("adminService.refundPayment", () => {
  const BOOKING_ID = "booking-1";
  const dec = (n: number) => ({ toNumber: () => n });

  beforeEach(() => vi.clearAllMocks());

  it("ném 404 khi không tìm thấy đơn", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue(null);
    await expect(
      adminService.refundPayment(ADMIN_ID, BOOKING_ID, {
        amount: 100,
        reason: "x",
      }),
    ).rejects.toBeInstanceOf(AppError);
  });

  it("ném 409 khi đơn chưa có thanh toán", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue({
      id: BOOKING_ID,
      renterId: "u1",
      payment: null,
    } as never);
    await expect(
      adminService.refundPayment(ADMIN_ID, BOOKING_ID, {
        amount: 100,
        reason: "x",
      }),
    ).rejects.toMatchObject({ code: "NO_PAYMENT" });
  });

  it("ném 409 khi payment chưa PAID", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue({
      id: BOOKING_ID,
      renterId: "u1",
      payment: { status: "PENDING", amount: dec(500) },
    } as never);
    await expect(
      adminService.refundPayment(ADMIN_ID, BOOKING_ID, {
        amount: 100,
        reason: "x",
      }),
    ).rejects.toMatchObject({ code: "PAYMENT_NOT_REFUNDABLE" });
  });

  it("ném 400 khi amount vượt số đã trả", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue({
      id: BOOKING_ID,
      renterId: "u1",
      payment: { status: "PAID", amount: dec(500) },
    } as never);
    await expect(
      adminService.refundPayment(ADMIN_ID, BOOKING_ID, {
        amount: 600,
        reason: "x",
      }),
    ).rejects.toMatchObject({ code: "INVALID_REFUND_AMOUNT" });
  });

  it("hoàn tiền hợp lệ → REFUNDED + báo người thuê", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue({
      id: BOOKING_ID,
      renterId: "u1",
      payment: { status: "PAID", amount: dec(500) },
    } as never);
    vi.mocked(adminRepository.refundPayment).mockResolvedValue({
      status: "REFUNDED",
    } as never);

    const r = await adminService.refundPayment(ADMIN_ID, BOOKING_ID, {
      amount: 500,
      reason: "Xe hỏng",
    });

    expect(r).toEqual({
      bookingId: BOOKING_ID,
      status: "REFUNDED",
      amount: 500,
    });
    expect(adminRepository.refundPayment).toHaveBeenCalledWith(
      BOOKING_ID,
      500,
      ADMIN_ID,
      "Xe hỏng",
    );
    expect(notificationService.notify).toHaveBeenCalledWith(
      expect.objectContaining({ userId: "u1", type: "PAYMENT" }),
    );
  });
});

describe("adminService.listRiskFlags", () => {
  beforeEach(() => vi.clearAllMocks());

  const fact = (over: Record<string, unknown>) => ({
    id: "u",
    phone: "0",
    email: null,
    roles: ["RENTER"],
    createdAt: new Date("2020-01-01"),
    total_bookings: 0,
    cancelled: 0,
    completed: 0,
    max_value: 0,
    self_rentals: 0,
    failed: 0,
    owned_total: 0,
    owned_completed: 0,
    ...over,
  });

  it("lọc bỏ user dưới ngưỡng + xếp điểm giảm dần", async () => {
    vi.mocked(adminRepository.getUserRiskFacts).mockResolvedValue([
      fact({ id: "clean" }), // score 0 → loại
      fact({ id: "med", failed: 3 }), // +2 MEDIUM
      fact({ id: "high", self_rentals: 1, failed: 3 }), // +5 HIGH
    ] as never);

    const result = await adminService.listRiskFlags();

    expect(result.map((r) => r.userId)).toEqual(["high", "med"]);
    expect(result[0].tier).toBe("HIGH");
    expect(result[0].reasons.length).toBeGreaterThan(0);
  });
});
