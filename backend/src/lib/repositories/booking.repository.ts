import { BookingStatus, type Booking, type Prisma } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Booking — CHỈ nơi đây gọi Prisma cho bảng Booking.

export interface CreateBookingData {
  vehicleId: string;
  renterId: string;
  startTime: Date;
  endTime: Date;
  totalPrice: number;
  deliveryRequested: boolean;
}

export interface ListBookingsParams {
  renterId: string;
  status?: BookingStatus;
  page: number;
  limit: number;
}

export interface ListBookingsByOwnerParams {
  ownerId: string;
  status?: BookingStatus;
  page: number;
  limit: number;
}

// Booking kèm xe + người thuê — phục vụ các màn của OWNER (yêu cầu đặt xe).
const OWNER_BOOKING_INCLUDE = {
  vehicle: { select: { id: true, title: true, type: true, ownerId: true } },
  renter: { select: { id: true, phone: true, email: true } },
} satisfies Prisma.BookingInclude;

export type BookingWithVehicleRenter = Prisma.BookingGetPayload<{
  include: typeof OWNER_BOOKING_INCLUDE;
}>;

// Trạng thái "chiếm chỗ" xe — khớp với EXCLUDE constraint booking_no_overlap.
// AWAITING_OWNER cũng khoá slot (khách đã trả tiền, chờ chủ xe xác nhận).
const ACTIVE_STATUSES: BookingStatus[] = [
  BookingStatus.AWAITING_OWNER,
  BookingStatus.CONFIRMED,
  BookingStatus.IN_PROGRESS,
];

export const bookingRepository = {
  create(data: CreateBookingData): Promise<Booking> {
    return prisma.booking.create({ data });
  },

  findById(id: string): Promise<Booking | null> {
    return prisma.booking.findUnique({ where: { id } });
  },

  async findManyByRenter(
    p: ListBookingsParams,
  ): Promise<{ items: Booking[]; total: number }> {
    const where: Prisma.BookingWhereInput = {
      renterId: p.renterId,
      ...(p.status && { status: p.status }),
    };
    const [items, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.booking.count({ where }),
    ]);
    return { items, total };
  },

  // Đơn đặt trên các xe của một OWNER (lọc qua vehicle.ownerId), kèm xe + người thuê.
  async findManyByOwner(
    p: ListBookingsByOwnerParams,
  ): Promise<{ items: BookingWithVehicleRenter[]; total: number }> {
    // Không truyền status → mặc định ẩn đơn PENDING_PAYMENT (khách chưa trả tiền),
    // owner chỉ thấy đơn đã thanh toán trở đi. Có truyền status thì lọc đúng status.
    const where: Prisma.BookingWhereInput = {
      vehicle: { ownerId: p.ownerId },
      ...(p.status
        ? { status: p.status }
        : { status: { not: BookingStatus.PENDING_PAYMENT } }),
    };
    const [items, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        include: OWNER_BOOKING_INCLUDE,
        orderBy: { createdAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.booking.count({ where }),
    ]);
    return { items, total };
  },

  findByIdForOwner(id: string): Promise<BookingWithVehicleRenter | null> {
    return prisma.booking.findUnique({
      where: { id },
      include: OWNER_BOOKING_INCLUDE,
    });
  },

  // Các đơn của một xe trong các trạng thái cho trước, từ thời điểm `from` trở đi
  // (suy ra lịch bận cho màn calendar/availability).
  findByVehicle(
    vehicleId: string,
    statuses: BookingStatus[],
    from?: Date,
  ): Promise<Booking[]> {
    return prisma.booking.findMany({
      where: {
        vehicleId,
        status: { in: statuses },
        ...(from && { endTime: { gte: from } }),
      },
      orderBy: { startTime: "asc" },
    });
  },

  // Chuyến đang chạy (IN_PROGRESS) của một xe — cho tracking (authz + gán bookingId).
  findInProgressByVehicle(vehicleId: string): Promise<Booking | null> {
    return prisma.booking.findFirst({
      where: { vehicleId, status: BookingStatus.IN_PROGRESS },
      orderBy: { startTime: "desc" },
    });
  },

  // Pre-check tầng ứng dụng: có booking đang chiếm chỗ chồng khoảng [start,end)?
  // EXCLUDE constraint là chốt cứng ở bước confirm (Phase 4).
  async hasActiveOverlap(
    vehicleId: string,
    start: Date,
    end: Date,
  ): Promise<boolean> {
    const count = await prisma.booking.count({
      where: {
        vehicleId,
        status: { in: ACTIVE_STATUSES },
        startTime: { lt: end },
        endTime: { gt: start },
      },
    });
    return count > 0;
  },

  // Đơn còn PENDING_PAYMENT nhưng đã tạo trước mốc `before` (quá hạn thanh toán).
  // Dùng cho cron tự huỷ. Không cần cờ "đã nhắc": sau khi huỷ, đơn chuyển sang
  // CANCELLED nên lần quét sau không còn khớp → tránh xử lý trùng.
  findOverduePendingPayment(before: Date, limit: number): Promise<Booking[]> {
    return prisma.booking.findMany({
      where: {
        status: BookingStatus.PENDING_PAYMENT,
        createdAt: { lt: before },
      },
      orderBy: { createdAt: "asc" },
      take: limit,
    });
  },

  // Đơn AWAITING_OWNER (đã trả tiền) mà chủ xe chưa xác nhận trước mốc `before`.
  // `updatedAt` = thời điểm chuyển sang AWAITING_OWNER (không có update nào khác ở
  // trạng thái này) → xấp xỉ "đã chờ xác nhận > X giờ". Dùng cho cron auto-refund.
  findOverdueAwaitingOwner(before: Date, limit: number): Promise<Booking[]> {
    return prisma.booking.findMany({
      where: {
        status: BookingStatus.AWAITING_OWNER,
        updatedAt: { lt: before },
      },
      orderBy: { updatedAt: "asc" },
      take: limit,
    });
  },

  // Đơn đã hết hạn thuê (endTime < before) mà vẫn CONFIRMED (chưa/không nhận xe)
  // hoặc IN_PROGRESS (đang thuê, quá hạn trả). Dùng cho cron tự hoàn thành. Kèm
  // vehicle.ownerId + title để báo cho cả hai phía.
  findOverdueEnded(
    before: Date,
    limit: number,
  ): Promise<BookingWithVehicleRenter[]> {
    return prisma.booking.findMany({
      where: {
        status: {
          in: [BookingStatus.CONFIRMED, BookingStatus.IN_PROGRESS],
        },
        endTime: { lt: before },
      },
      include: OWNER_BOOKING_INCLUDE,
      orderBy: { endTime: "asc" },
      take: limit,
    });
  },

  updateStatus(id: string, status: BookingStatus): Promise<Booking> {
    return prisma.booking.update({ where: { id }, data: { status } });
  },

  // Chuyển trạng thái CÓ ĐIỀU KIỆN (compare-and-swap): chỉ đổi nếu status hiện tại
  // nằm trong `from`. Trả về booking đã đổi, hoặc null nếu không khớp (đã bị caller
  // khác đổi trước — dùng để chống race approve/reject/cancel/cron-expire).
  async updateStatusIf(
    id: string,
    from: BookingStatus[],
    to: BookingStatus,
  ): Promise<Booking | null> {
    const result = await prisma.booking.updateMany({
      where: { id, status: { in: from } },
      data: { status: to },
    });
    if (result.count === 0) return null;
    return prisma.booking.findUnique({ where: { id } });
  },
};
