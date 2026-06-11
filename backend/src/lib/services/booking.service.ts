import { BookingStatus, type Booking } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import {
  bookingRepository,
  type ListBookingsParams,
} from "@/lib/repositories/booking.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import type { CreateBookingInput } from "@/lib/validators/booking.validator";

const MS_PER_HOUR = 3_600_000;

export interface PublicBooking {
  id: string;
  vehicleId: string;
  renterId: string;
  status: BookingStatus;
  startTime: Date;
  endTime: Date;
  totalPrice: number;
  deliveryRequested: boolean;
  createdAt: Date;
}

export interface BookingListResult {
  items: PublicBooking[];
  total: number;
  page: number;
  limit: number;
}

// Trạng thái còn được phép huỷ.
const CANCELLABLE: BookingStatus[] = [
  BookingStatus.PENDING_PAYMENT,
  BookingStatus.CONFIRMED,
];

function toPublicBooking(b: Booking): PublicBooking {
  return {
    id: b.id,
    vehicleId: b.vehicleId,
    renterId: b.renterId,
    status: b.status,
    startTime: b.startTime,
    endTime: b.endTime,
    totalPrice: Number(b.totalPrice),
    deliveryRequested: b.deliveryRequested,
    createdAt: b.createdAt,
  };
}

async function loadOwned(id: string, renterId: string): Promise<Booking> {
  const booking = await bookingRepository.findById(id);
  if (!booking) {
    throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
  }
  if (booking.renterId !== renterId) {
    throw new AppError(403, "FORBIDDEN", "Đây không phải đơn của bạn");
  }
  return booking;
}

export const bookingService = {
  async create(
    renterId: string,
    input: CreateBookingInput,
  ): Promise<PublicBooking> {
    const vehicle = await vehicleRepository.findById(input.vehicleId);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }
    if (!vehicle.isAvailable) {
      throw new AppError(409, "VEHICLE_UNAVAILABLE", "Xe hiện không sẵn sàng");
    }
    if (input.deliveryRequested && !vehicle.deliveryAvailable) {
      throw new AppError(
        400,
        "DELIVERY_UNAVAILABLE",
        "Xe này không hỗ trợ giao tận nơi",
      );
    }

    const start = new Date(input.startTime);
    const end = new Date(input.endTime);
    if (await bookingRepository.hasActiveOverlap(vehicle.id, start, end)) {
      throw new AppError(
        409,
        "BOOKING_CONFLICT",
        "Xe đã có người đặt trong khoảng thời gian này",
      );
    }

    // Làm tròn lên theo giờ; tối thiểu 1 giờ.
    const hours = Math.max(
      1,
      Math.ceil((end.getTime() - start.getTime()) / MS_PER_HOUR),
    );
    const totalPrice = Number(vehicle.pricePerHour) * hours;

    const booking = await bookingRepository.create({
      vehicleId: vehicle.id,
      renterId,
      startTime: start,
      endTime: end,
      totalPrice,
      deliveryRequested: input.deliveryRequested,
    });
    return toPublicBooking(booking);
  },

  async list(
    params: Omit<ListBookingsParams, "renterId"> & { renterId: string },
  ): Promise<BookingListResult> {
    const { items, total } = await bookingRepository.findManyByRenter(params);
    return {
      items: items.map(toPublicBooking),
      total,
      page: params.page,
      limit: params.limit,
    };
  },

  async getById(renterId: string, id: string): Promise<PublicBooking> {
    return toPublicBooking(await loadOwned(id, renterId));
  },

  async cancel(renterId: string, id: string): Promise<PublicBooking> {
    const booking = await loadOwned(id, renterId);
    if (!CANCELLABLE.includes(booking.status)) {
      throw new AppError(
        409,
        "BOOKING_NOT_CANCELLABLE",
        "Đơn này không thể huỷ ở trạng thái hiện tại",
      );
    }
    const updated = await bookingRepository.updateStatus(
      id,
      BookingStatus.CANCELLED,
    );
    return toPublicBooking(updated);
  },
};
