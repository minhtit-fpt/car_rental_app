import { DisputeStatus, UserRole, VehicleApprovalStatus } from "@prisma/client";
import type {
  BookingStatus,
  DisputePriority,
  InspectionPhase,
  KycStatus,
  PaymentMethod,
  PaymentStatus,
  VehicleType,
} from "@prisma/client";
import { PaymentStatus as PaymentStatusEnum } from "@prisma/client";
import { adminRepository } from "@/lib/repositories/admin.repository";
import { llmClient } from "@/lib/ai/llm.client";
import { notificationService } from "@/lib/services/notification.service";
import {
  RISK_FLAG_MIN_SCORE,
  scoreRisk,
  type RiskReason,
  type RiskTier,
} from "@/lib/services/risk.scoring";
import { AppError } from "@/lib/errors/app-error";
import type {
  ListBookingsInput,
  ListDisputesInput,
  ListKycInput,
  ListUsersInput,
  ListVehiclesInput,
  RefundPaymentInput,
  ResolveDisputeInput,
  ReviewVehicleInput,
  UpdateUserRoleInput,
} from "@/lib/validators/admin.validator";

export interface AdminStats {
  totalUsers: number;
  activeBookings: number;
  pendingKyc: number;
  monthlyRevenue: number;
}

export interface BookingStatusMetric {
  status: BookingStatus;
  count: number;
}

export interface PaymentMethodMetric {
  method: PaymentMethod;
  total: number;
}

export interface VehicleTypeMetric {
  type: VehicleType;
  count: number;
  electric: number;
}

export interface TopVehicle {
  id: string;
  title: string;
  revenue: number;
  trips: number;
}

export interface RecentBooking {
  id: string;
  vehicleTitle: string;
  status: BookingStatus;
  totalPrice: number;
  createdAt: string;
}

export interface AdminMetrics {
  kpi: {
    totalUsers: number;
    totalVehicles: number;
    availableVehicles: number;
    electricVehicles: number;
    totalBookings: number;
    completionRate: number; // 0..1
    cancellationRate: number; // 0..1
    avgRating: number;
  };
  bookingsByStatus: BookingStatusMetric[];
  paymentsByMethod: PaymentMethodMetric[];
  vehiclesByType: VehicleTypeMetric[];
  topVehicles: TopVehicle[];
  recentBookings: RecentBooking[];
}

export interface AdminUserItem {
  id: string;
  phone: string;
  email: string | null;
  roles: UserRole[];
  kycStatus: KycStatus;
  createdAt: string;
}

export interface AdminVehicleItem {
  id: string;
  title: string;
  type: VehicleType;
  pricePerHour: number;
  isElectric: boolean;
  city: string | null;
  approvalStatus: VehicleApprovalStatus;
  rejectionReason: string | null;
  createdAt: string;
  owner: { id: string; phone: string; email: string | null };
}

export interface AdminBookingItem {
  id: string;
  vehicleTitle: string;
  status: BookingStatus;
  totalPrice: number;
  startTime: string;
  endTime: string;
  createdAt: string;
  paymentStatus: PaymentStatus | null;
}

export interface AdminBookingDetail {
  id: string;
  status: BookingStatus;
  startTime: string;
  endTime: string;
  totalPrice: number;
  deliveryRequested: boolean;
  createdAt: string;
  vehicle: { id: string; title: string; type: VehicleType };
  renter: { id: string; phone: string; email: string | null };
  payment: {
    method: PaymentMethod;
    status: PaymentStatus;
    amount: number;
    gatewayRef: string | null;
    paidAt: string | null;
  } | null;
  contract: { pdfUrl: string; signedAt: string | null } | null;
  inspections: { phase: InspectionPhase; photoCount: number; createdAt: string }[];
  disputes: {
    id: string;
    title: string;
    status: DisputeStatus;
    priority: DisputePriority;
    createdAt: string;
  }[];
  damageReport: { summary: string; estimatedCost: number } | null;
}

export interface AdminRiskItem {
  userId: string;
  phone: string;
  email: string | null;
  roles: UserRole[];
  score: number;
  tier: RiskTier;
  reasons: RiskReason[];
}

export interface AdminKycItem {
  id: string;
  userId: string;
  phone: string;
  email: string | null;
  status: KycStatus;
  submittedAt: string;
}

export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export interface RevenuePoint {
  month: string; // 'YYYY-MM'
  total: number;
}

export interface AdminDisputeItem {
  id: string;
  bookingId: string;
  title: string;
  priority: DisputePriority;
  status: DisputeStatus;
  createdAt: string;
}

function startOfCurrentMonth(now: Date = new Date()): Date {
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

function monthKey(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

function toAdminUserItem(u: {
  id: string;
  phone: string;
  email: string | null;
  roles: UserRole[];
  kycStatus: KycStatus;
  createdAt: Date;
}): AdminUserItem {
  return {
    id: u.id,
    phone: u.phone,
    email: u.email,
    roles: u.roles,
    kycStatus: u.kycStatus,
    createdAt: u.createdAt.toISOString(),
  };
}

export const adminService = {
  async getStats(): Promise<AdminStats> {
    const [totalUsers, activeBookings, pendingKyc, monthlyRevenue] =
      await Promise.all([
        adminRepository.countUsers(),
        adminRepository.countActiveBookings(),
        adminRepository.countPendingKyc(),
        adminRepository.sumRevenueSince(startOfCurrentMonth()),
      ]);
    return { totalUsers, activeBookings, pendingKyc, monthlyRevenue };
  },

  // Gom mọi aggregation cho dashboard vào 1 object (1 endpoint). Cũng là tập
  // query whitelist cho NL-analytics Phase 5 → không viết truy vấn hai lần.
  async getMetrics(): Promise<AdminMetrics> {
    const [
      totalUsers,
      bookingGroups,
      paymentGroups,
      vehicleGroups,
      availableVehicles,
      avgRating,
      topVehicles,
      recent,
    ] = await Promise.all([
      adminRepository.countUsers(),
      adminRepository.groupBookingsByStatus(),
      adminRepository.groupPaymentsByMethodPaid(),
      adminRepository.groupVehiclesByTypeElectric(),
      adminRepository.countAvailableVehicles(),
      adminRepository.avgReviewRating(),
      adminRepository.topVehiclesByRevenue(5),
      adminRepository.recentBookings(10),
    ]);

    const bookingsByStatus: BookingStatusMetric[] = bookingGroups.map((g) => ({
      status: g.status,
      count: g._count._all,
    }));
    const totalBookings = bookingsByStatus.reduce((s, b) => s + b.count, 0);
    const countFor = (status: BookingStatus): number =>
      bookingsByStatus.find((b) => b.status === status)?.count ?? 0;

    const paymentsByMethod: PaymentMethodMetric[] = paymentGroups.map((g) => ({
      method: g.method,
      total: g._sum.amount?.toNumber() ?? 0,
    }));

    // Gộp [type, isElectric] → mỗi loại 1 dòng { count, electric }.
    const typeMap = new Map<VehicleType, { count: number; electric: number }>();
    for (const g of vehicleGroups) {
      const cur = typeMap.get(g.type) ?? { count: 0, electric: 0 };
      cur.count += g._count._all;
      if (g.isElectric) cur.electric += g._count._all;
      typeMap.set(g.type, cur);
    }
    const vehiclesByType: VehicleTypeMetric[] = [...typeMap.entries()].map(
      ([type, v]) => ({ type, count: v.count, electric: v.electric }),
    );
    const totalVehicles = vehiclesByType.reduce((s, v) => s + v.count, 0);
    const electricVehicles = vehiclesByType.reduce((s, v) => s + v.electric, 0);

    return {
      kpi: {
        totalUsers,
        totalVehicles,
        availableVehicles,
        electricVehicles,
        totalBookings,
        completionRate: totalBookings ? countFor("COMPLETED") / totalBookings : 0,
        cancellationRate: totalBookings
          ? countFor("CANCELLED") / totalBookings
          : 0,
        avgRating,
      },
      bookingsByStatus,
      paymentsByMethod,
      vehiclesByType,
      topVehicles,
      recentBookings: recent.map((r) => ({
        id: r.id,
        vehicleTitle: r.vehicle.title,
        status: r.status,
        totalPrice: r.totalPrice.toNumber(),
        createdAt: r.createdAt.toISOString(),
      })),
    };
  },

  // Chuỗi doanh thu `months` tháng gần nhất (cũ → mới), bù 0 cho tháng trống.
  async getRevenueSeries(months: number): Promise<RevenuePoint[]> {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth() - (months - 1), 1);
    const rows = await adminRepository.monthlyRevenue(start);

    const totals = new Map<string, number>();
    for (const row of rows) {
      totals.set(monthKey(new Date(row.month)), Number(row.total));
    }

    const series: RevenuePoint[] = [];
    for (let i = 0; i < months; i += 1) {
      const d = new Date(now.getFullYear(), now.getMonth() - (months - 1) + i, 1);
      const key = monthKey(d);
      series.push({ month: key, total: totals.get(key) ?? 0 });
    }
    return series;
  },

  async listDisputes(
    input: ListDisputesInput,
  ): Promise<Paginated<AdminDisputeItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findDisputes(
      input.status,
      skip,
      input.limit,
    );
    return {
      items: rows.map((d) => ({
        id: d.id,
        bookingId: d.bookingId,
        title: d.title,
        priority: d.priority,
        status: d.status,
        createdAt: d.createdAt.toISOString(),
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },

  // ADMIN giải quyết/bác bỏ tranh chấp. Baseline (KHÔNG đụng tiền — refund tách
  // riêng). Đổi trạng thái + ghi audit + báo cho người tạo tranh chấp.
  async resolveDispute(
    adminId: string,
    id: string,
    input: ResolveDisputeInput,
  ): Promise<{ id: string; status: DisputeStatus }> {
    const dispute = await adminRepository.findDisputeById(id);
    if (!dispute) {
      throw new AppError(404, "DISPUTE_NOT_FOUND", "Không tìm thấy tranh chấp");
    }

    const status =
      input.decision === "resolve"
        ? DisputeStatus.RESOLVED
        : DisputeStatus.REJECTED;

    const updated = await adminRepository.resolveDispute(
      id,
      status,
      adminId,
      input.note,
    );

    const resolved = status === DisputeStatus.RESOLVED;
    await notificationService.notify({
      userId: dispute.raisedById,
      type: "SYSTEM",
      title: resolved ? "Khiếu nại đã được giải quyết" : "Khiếu nại bị bác bỏ",
      body:
        input.note ??
        (resolved
          ? "Khiếu nại của bạn đã được xử lý."
          : "Khiếu nại của bạn không được chấp nhận."),
    });

    return updated;
  },

  async listUsers(input: ListUsersInput): Promise<Paginated<AdminUserItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findUsers({
      skip,
      take: input.limit,
      role: input.role,
      search: input.search,
    });
    return {
      items: rows.map(toAdminUserItem),
      total,
      page: input.page,
      limit: input.limit,
    };
  },

  // ADMIN bật/tắt vai OWNER cho user. Idempotent (add khi đã có / remove khi
  // chưa có → no-op). Không cho đổi vai tài khoản ADMIN (user_admin_exclusive).
  async setUserRole(
    adminId: string,
    userId: string,
    input: UpdateUserRoleInput,
  ): Promise<AdminUserItem> {
    const user = await adminRepository.findUserById(userId);
    if (!user) {
      throw new AppError(404, "USER_NOT_FOUND", "Không tìm thấy người dùng");
    }
    if (user.roles.includes(UserRole.ADMIN)) {
      throw new AppError(
        409,
        "ADMIN_ROLE_LOCKED",
        "Không thể đổi vai trò của tài khoản ADMIN",
      );
    }

    const has = user.roles.includes(input.role);
    const roles =
      input.action === "add"
        ? has
          ? user.roles
          : [...user.roles, input.role]
        : user.roles.filter((r) => r !== input.role);

    const updated = await adminRepository.setUserRoles(
      userId,
      roles,
      adminId,
      `USER_ROLE_${input.action.toUpperCase()}`,
      input.role,
    );
    return toAdminUserItem(updated);
  },

  async listVehicles(
    input: ListVehiclesInput,
  ): Promise<Paginated<AdminVehicleItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findVehiclesForReview(
      input.status,
      skip,
      input.limit,
    );
    return {
      items: rows.map((v) => ({
        id: v.id,
        title: v.title,
        type: v.type,
        pricePerHour: v.pricePerHour.toNumber(),
        isElectric: v.isElectric,
        city: v.city,
        approvalStatus: v.approvalStatus,
        rejectionReason: v.rejectionReason,
        createdAt: v.createdAt.toISOString(),
        owner: v.owner,
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },

  // ADMIN duyệt/từ chối xe → đổi approvalStatus + ghi audit + báo chủ xe.
  async reviewVehicle(
    adminId: string,
    id: string,
    input: ReviewVehicleInput,
  ): Promise<{
    id: string;
    approvalStatus: VehicleApprovalStatus;
    rejectionReason: string | null;
  }> {
    const vehicle = await adminRepository.findVehicleOwner(id);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }

    const approved = input.decision === "approve";
    const status = approved
      ? VehicleApprovalStatus.APPROVED
      : VehicleApprovalStatus.REJECTED;
    const reason = approved ? null : (input.rejectionReason ?? null);

    const updated = await adminRepository.setVehicleApproval(
      id,
      status,
      adminId,
      reason,
    );

    await notificationService.notify({
      userId: vehicle.ownerId,
      type: "SYSTEM",
      title: approved ? "Xe đã được duyệt" : "Xe bị từ chối",
      body: approved
        ? `"${vehicle.title}" đã được duyệt và hiển thị cho người thuê.`
        : `"${vehicle.title}" bị từ chối: ${reason}`,
    });

    return updated;
  },

  async listBookings(
    input: ListBookingsInput,
  ): Promise<Paginated<AdminBookingItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findBookings({
      status: input.status,
      from: input.from,
      to: input.to,
      skip,
      take: input.limit,
    });
    return {
      items: rows.map((b) => ({
        id: b.id,
        vehicleTitle: b.vehicle.title,
        status: b.status,
        totalPrice: b.totalPrice.toNumber(),
        startTime: b.startTime.toISOString(),
        endTime: b.endTime.toISOString(),
        createdAt: b.createdAt.toISOString(),
        paymentStatus: b.payment?.status ?? null,
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },

  async getBookingDetail(id: string): Promise<AdminBookingDetail> {
    const b = await adminRepository.findBookingDetail(id);
    if (!b) {
      throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn");
    }
    return {
      id: b.id,
      status: b.status,
      startTime: b.startTime.toISOString(),
      endTime: b.endTime.toISOString(),
      totalPrice: b.totalPrice.toNumber(),
      deliveryRequested: b.deliveryRequested,
      createdAt: b.createdAt.toISOString(),
      vehicle: b.vehicle,
      renter: b.renter,
      payment: b.payment
        ? {
            method: b.payment.method,
            status: b.payment.status,
            amount: b.payment.amount.toNumber(),
            gatewayRef: b.payment.gatewayRef,
            paidAt: b.payment.paidAt?.toISOString() ?? null,
          }
        : null,
      contract: b.contract
        ? {
            pdfUrl: b.contract.pdfUrl,
            signedAt: b.contract.signedAt?.toISOString() ?? null,
          }
        : null,
      // photoKeys là object key bucket private → chỉ lộ số lượng, không lộ key.
      inspections: b.inspections.map((i) => ({
        phase: i.phase,
        photoCount: i.photoKeys.length,
        createdAt: i.createdAt.toISOString(),
      })),
      disputes: b.disputes.map((d) => ({
        id: d.id,
        title: d.title,
        status: d.status,
        priority: d.priority,
        createdAt: d.createdAt.toISOString(),
      })),
      damageReport: b.damageReport,
    };
  },

  // ADMIN hoàn tiền: đánh dấu Payment REFUNDED + audit + báo người thuê. Chỉ
  // hoàn được payment đã PAID; amount phải ≤ số đã trả. KHÔNG gọi cổng thật.
  async refundPayment(
    adminId: string,
    bookingId: string,
    input: RefundPaymentInput,
  ): Promise<{ bookingId: string; status: PaymentStatus; amount: number }> {
    const booking = await adminRepository.findBookingForRefund(bookingId);
    if (!booking) {
      throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn");
    }
    if (!booking.payment) {
      throw new AppError(409, "NO_PAYMENT", "Đơn chưa có thanh toán");
    }
    if (booking.payment.status !== PaymentStatusEnum.PAID) {
      throw new AppError(
        409,
        "PAYMENT_NOT_REFUNDABLE",
        "Chỉ hoàn được thanh toán đã thanh toán thành công",
      );
    }
    if (input.amount > booking.payment.amount.toNumber()) {
      throw new AppError(
        400,
        "INVALID_REFUND_AMOUNT",
        "Số tiền hoàn vượt quá số tiền đã thanh toán",
      );
    }

    const updated = await adminRepository.refundPayment(
      bookingId,
      input.amount,
      adminId,
      input.reason,
    );

    await notificationService.notify({
      userId: booking.renterId,
      type: "PAYMENT",
      title: "Đơn của bạn đã được hoàn tiền",
      body: `Đã hoàn ${input.amount.toLocaleString("vi-VN")}đ. Lý do: ${input.reason}`,
    });

    return { bookingId, status: updated.status, amount: input.amount };
  },

  // Hàng đợi rủi ro: chấm điểm mọi user qua rule-engine, chỉ giữ tier ≥ MEDIUM,
  // xếp điểm giảm dần. Lời giải thích = các rule đã kích hoạt (explainable).
  async listRiskFlags(): Promise<AdminRiskItem[]> {
    const rows = await adminRepository.getUserRiskFacts();
    const now = Date.now();
    const dayMs = 24 * 60 * 60 * 1000;

    return rows
      .map((r) => {
        const result = scoreRisk({
          accountAgeDays: Math.floor((now - r.createdAt.getTime()) / dayMs),
          totalBookings: r.total_bookings,
          cancelledBookings: r.cancelled,
          completedBookings: r.completed,
          maxBookingValue: r.max_value,
          failedPayments: r.failed,
          selfRentals: r.self_rentals,
          ownedBookings: r.owned_total,
          ownedCompleted: r.owned_completed,
          roles: r.roles,
        });
        return {
          userId: r.id,
          phone: r.phone,
          email: r.email,
          roles: r.roles,
          score: result.score,
          tier: result.tier,
          reasons: result.reasons,
        };
      })
      .filter((x) => x.score >= RISK_FLAG_MIN_SCORE)
      .sort((a, b) => b.score - a.score);
  },

  // 5b-tail: AI viết lời giải thích "vì sao bị cờ" từ các rule ĐÃ kích hoạt
  // (không chấm điểm bằng LLM — giữ kiểm toán được). Advisory; offline → null.
  async explainRiskFlag(
    userId: string,
  ): Promise<{ explanation: string | null; aiError: string | null }> {
    const flag = (await this.listRiskFlags()).find((f) => f.userId === userId);
    if (!flag) {
      throw new AppError(404, "RISK_FLAG_NOT_FOUND", "Người dùng không bị cờ rủi ro");
    }
    const reasons = flag.reasons.map((r) => `- ${r.label}`).join("\n");
    try {
      const explanation = await llmClient.chat([
        {
          role: "system",
          content:
            "Bạn giải thích ngắn gọn (2-3 câu, tiếng Việt) vì sao một tài khoản bị gắn cờ rủi ro, CHỈ dựa trên các dấu hiệu đã liệt kê. KHÔNG bịa thêm dấu hiệu, KHÔNG đưa số liệu không có.",
        },
        {
          role: "user",
          content: `Mức rủi ro: ${flag.tier} (điểm ${flag.score}).\nCác dấu hiệu đã kích hoạt:\n${reasons}`,
        },
      ]);
      return { explanation: explanation.trim(), aiError: null };
    } catch (error) {
      const aiError =
        error instanceof AppError ? error.message : "Chưa tạo được giải thích";
      return { explanation: null, aiError };
    }
  },

  async listKyc(input: ListKycInput): Promise<Paginated<AdminKycItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findKycQueue(
      input.status,
      skip,
      input.limit,
    );
    return {
      items: rows.map((k) => ({
        id: k.id,
        userId: k.userId,
        phone: k.user.phone,
        email: k.user.email,
        status: k.status,
        submittedAt: k.createdAt.toISOString(),
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },
};
