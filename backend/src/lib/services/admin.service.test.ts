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
