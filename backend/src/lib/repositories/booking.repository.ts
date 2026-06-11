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

// Trạng thái "chiếm chỗ" xe — khớp với EXCLUDE constraint booking_no_overlap.
const ACTIVE_STATUSES: BookingStatus[] = [
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

  updateStatus(id: string, status: BookingStatus): Promise<Booking> {
    return prisma.booking.update({ where: { id }, data: { status } });
  },
};
