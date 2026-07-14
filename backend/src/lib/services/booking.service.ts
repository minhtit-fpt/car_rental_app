import { BookingStatus, VehicleType, type Booking } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import {
  bookingRepository,
  type BookingWithVehicleRenter,
  type ListBookingsByOwnerParams,
  type ListBookingsParams,
} from "@/lib/repositories/booking.repository";
import { userRepository } from "@/lib/repositories/user.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { notificationEvents } from "@/lib/services/notification.events";
import { notificationService } from "@/lib/services/notification.service";
import { pricingService } from "@/lib/services/pricing.service";
import { refundService } from "@/lib/services/refund.service";
import type { CreateBookingInput } from "@/lib/validators/booking.validator";

const MS_PER_HOUR = 3_600_000;

// Cửa sổ chủ xe xác nhận: đơn AWAITING_OWNER (đã trả tiền) quá ngần này giờ mà
// chủ xe chưa xác nhận sẽ bị cron tự huỷ + hoàn tiền. Mặc định 24 giờ.
const OWNER_APPROVAL_WINDOW_HOURS = 24;

// Cửa sổ thanh toán: đơn PENDING_PAYMENT quá ngần này giờ kể từ khi tạo sẽ bị
// cron tự huỷ. Cấu hình qua PAYMENT_REMINDER_HOURS (mặc định 1 giờ).
const DEFAULT_PAYMENT_WINDOW_HOURS = 1;
// Giới hạn số đơn xử lý mỗi lần quét để tránh batch quá lớn.
const EXPIRE_BATCH_LIMIT = 100;

function getPaymentWindowHours(): number {
  const raw = Number(process.env.PAYMENT_REMINDER_HOURS);
  return Number.isFinite(raw) && raw > 0 ? raw : DEFAULT_PAYMENT_WINDOW_HOURS;
}

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

// Đơn đặt nhìn từ phía OWNER — kèm thông tin xe + người thuê để hiển thị.
export interface OwnerBooking extends PublicBooking {
  vehicle: { id: string; title: string; type: VehicleType };
  renter: { id: string; phone: string; email: string | null };
}

export interface OwnerBookingListResult {
  items: OwnerBooking[];
  total: number;
  page: number;
  limit: number;
}

// Trạng thái owner được phép phê duyệt/từ chối: đơn đã trả tiền, chờ xác nhận.
const OWNER_ACTIONABLE: BookingStatus[] = [BookingStatus.AWAITING_OWNER];

// Trạng thái còn được phép huỷ.
const CANCELLABLE: BookingStatus[] = [
  BookingStatus.PENDING_PAYMENT,
  BookingStatus.CONFIRMED,
];

// EXCLUDE constraint chống đặt trùng giờ ném lỗi Postgres 23P01 khi chuyển sang
// CONFIRMED. Nhận diện để map sang 409 thay vì 500.
function isOverlapViolation(error: unknown): boolean {
  const message = error instanceof Error ? error.message : String(error);
  return message.includes("23P01") || message.includes("booking_no_overlap");
}

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

function toOwnerBooking(b: BookingWithVehicleRenter): OwnerBooking {
  return {
    ...toPublicBooking(b),
    vehicle: { id: b.vehicle.id, title: b.vehicle.title, type: b.vehicle.type },
    renter: { id: b.renter.id, phone: b.renter.phone, email: b.renter.email },
  };
}

// Tải đơn và xác nhận người gọi là CHỦ XE của đơn đó (qua vehicle.ownerId).
async function loadOwnedByVehicleOwner(
  id: string,
  ownerId: string,
): Promise<BookingWithVehicleRenter> {
  const booking = await bookingRepository.findByIdForOwner(id);
  if (!booking) {
    throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
  }
  if (booking.vehicle.ownerId !== ownerId) {
    throw new AppError(403, "FORBIDDEN", "Đây không phải xe của bạn");
  }
  return booking;
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
    if (vehicle.approvalStatus !== "APPROVED") {
      throw new AppError(409, "VEHICLE_NOT_APPROVED", "Xe chưa được duyệt");
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

    // Giá động: giá gốc (DB, do chủ xe đặt) × các yếu tố surge (giờ cao điểm,
    // cuối tuần/lễ, giảm giá thuê dài). Xem pricing.service / surge.util.
    const totalPrice = pricingService.quote({
      pricePerDay: Number(vehicle.pricePerDay),
      startTime: start,
      endTime: end,
    }).finalPrice;

    const booking = await bookingRepository.create({
      vehicleId: vehicle.id,
      renterId,
      startTime: start,
      endTime: end,
      totalPrice,
      deliveryRequested: input.deliveryRequested,
    });

    // Chỉ báo renter (chờ thanh toán). Owner được báo sau khi thanh toán
    // (paymentAwaitingOwner). safeCreate: lỗi noti KHÔNG làm hỏng luồng tạo đơn.
    await notificationEvents.bookingCreated({
      bookingId: booking.id,
      renterId,
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

  // Danh sách đơn đặt trên các xe của OWNER (lọc theo vehicle.ownerId).
  async listForOwner(
    params: Omit<ListBookingsByOwnerParams, "ownerId"> & { ownerId: string },
  ): Promise<OwnerBookingListResult> {
    const { items, total } = await bookingRepository.findManyByOwner(params);
    return {
      items: items.map(toOwnerBooking),
      total,
      page: params.page,
      limit: params.limit,
    };
  },

  // OWNER chấp nhận yêu cầu: AWAITING_OWNER (đã trả tiền) → CONFIRMED.
  // Slot đã được khoá từ lúc thanh toán; EXCLUDE constraint là chốt cứng cuối.
  async approve(ownerId: string, id: string): Promise<OwnerBooking> {
    const booking = await loadOwnedByVehicleOwner(id, ownerId);
    if (!OWNER_ACTIONABLE.includes(booking.status)) {
      throw new AppError(
        409,
        "BOOKING_NOT_APPROVABLE",
        "Đơn không ở trạng thái chờ xác nhận",
      );
    }
    if (
      await bookingRepository.hasActiveOverlap(
        booking.vehicleId,
        booking.startTime,
        booking.endTime,
      )
    ) {
      throw new AppError(
        409,
        "BOOKING_CONFLICT",
        "Xe đã có người đặt trong khoảng thời gian này",
      );
    }
    try {
      // Compare-and-swap: chỉ xác nhận nếu vẫn AWAITING_OWNER (chống race với
      // reject/cron-expire cùng đơn → tránh CONFIRMED khi tiền đã REFUNDED).
      const confirmed = await bookingRepository.updateStatusIf(
        id,
        [BookingStatus.AWAITING_OWNER],
        BookingStatus.CONFIRMED,
      );
      if (!confirmed) {
        throw new AppError(
          409,
          "BOOKING_NOT_APPROVABLE",
          "Đơn không ở trạng thái chờ xác nhận",
        );
      }
    } catch (error) {
      if (isOverlapViolation(error)) {
        throw new AppError(
          409,
          "BOOKING_CONFLICT",
          "Xe đã có người đặt trong khoảng thời gian này",
        );
      }
      throw error;
    }
    // Báo cho người thuê đơn đã được chủ xe xác nhận (đã thanh toán trước đó).
    await notificationService.notify({
      userId: booking.renterId,
      type: "BOOKING",
      title: "Đơn đặt đã được xác nhận",
      body: `${booking.vehicle.title} đã được chủ xe xác nhận. Chúc bạn có chuyến đi vui vẻ!`,
      payload: { bookingId: booking.id, role: "renter" },
    });
    return toOwnerBooking(await loadOwnedByVehicleOwner(id, ownerId));
  },

  // OWNER từ chối yêu cầu: AWAITING_OWNER → CANCELLED + tự hoàn tiền (đã trả).
  async reject(ownerId: string, id: string): Promise<OwnerBooking> {
    const booking = await loadOwnedByVehicleOwner(id, ownerId);
    if (!OWNER_ACTIONABLE.includes(booking.status)) {
      throw new AppError(
        409,
        "BOOKING_NOT_REJECTABLE",
        "Đơn không ở trạng thái chờ xác nhận",
      );
    }
    // Giành quyền huỷ TRƯỚC bằng compare-and-swap (chống race với approve/cron):
    // chỉ caller đổi được AWAITING_OWNER → CANCELLED mới hoàn tiền + báo.
    const cancelled = await bookingRepository.updateStatusIf(
      id,
      [BookingStatus.AWAITING_OWNER],
      BookingStatus.CANCELLED,
    );
    if (!cancelled) {
      throw new AppError(
        409,
        "BOOKING_NOT_REJECTABLE",
        "Đơn không ở trạng thái chờ xác nhận",
      );
    }
    const refund = await refundService.refundBookingPayment({
      bookingId: id,
      actorId: null,
      reason: "Chủ xe từ chối đơn đặt",
    });
    // Chỉ báo khi chính lần này thực hiện hoàn tiền (tránh noti trùng nếu đã bị
    // caller khác hoàn trước đó).
    if (refund.refunded) {
      await notificationService.notify({
        userId: booking.renterId,
        type: "BOOKING",
        title: "Đơn đặt bị từ chối",
        body: `${booking.vehicle.title} đã bị chủ xe từ chối. Số tiền đã thanh toán sẽ được hoàn lại.`,
        payload: { bookingId: booking.id, role: "renter" },
      });
    }
    return toOwnerBooking(await loadOwnedByVehicleOwner(id, ownerId));
  },

  // Gọi bởi payment.service sau khi thanh toán thành công. Chuyển
  // PENDING_PAYMENT → AWAITING_OWNER (CHƯA confirmed — còn chờ chủ xe xác nhận).
  // Khoá slot ngay (AWAITING_OWNER nằm trong EXCLUDE constraint). Idempotent nếu
  // đã AWAITING_OWNER/CONFIRMED. Ownership đã được payment.service kiểm tra.
  async confirmAfterPayment(bookingId: string): Promise<PublicBooking> {
    const booking = await bookingRepository.findById(bookingId);
    if (!booking) {
      throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
    }
    if (
      booking.status === BookingStatus.AWAITING_OWNER ||
      booking.status === BookingStatus.CONFIRMED
    ) {
      return toPublicBooking(booking);
    }
    if (booking.status !== BookingStatus.PENDING_PAYMENT) {
      throw new AppError(
        409,
        "BOOKING_NOT_CONFIRMABLE",
        "Đơn không ở trạng thái chờ thanh toán",
      );
    }
    // Pre-check tầng ứng dụng; EXCLUDE constraint là chốt cứng cuối cùng.
    if (
      await bookingRepository.hasActiveOverlap(
        booking.vehicleId,
        booking.startTime,
        booking.endTime,
      )
    ) {
      throw new AppError(
        409,
        "BOOKING_CONFLICT",
        "Xe đã có người đặt trong khoảng thời gian này",
      );
    }
    let updated: Booking;
    try {
      updated = await bookingRepository.updateStatus(
        bookingId,
        BookingStatus.AWAITING_OWNER,
      );
    } catch (error) {
      if (isOverlapViolation(error)) {
        throw new AppError(
          409,
          "BOOKING_CONFLICT",
          "Xe đã có người đặt trong khoảng thời gian này",
        );
      }
      throw error;
    }

    const vehicle = await vehicleRepository.findById(updated.vehicleId);
    if (vehicle) {
      const renter = await userRepository.findById(updated.renterId);
      await notificationEvents.paymentAwaitingOwner({
        bookingId: updated.id,
        renterId: updated.renterId,
        ownerId: vehicle.ownerId,
        renterEmail: renter?.email,
      });
    }
    return toPublicBooking(updated);
  },

  // Quét & tự huỷ các đơn AWAITING_OWNER quá hạn chủ xe xác nhận (gọi bởi cron).
  // Mỗi đơn: hoàn tiền (đã trả) → AWAITING_OWNER → CANCELLED + noti renter.
  // Lỗi 1 đơn không chặn các đơn còn lại. Trả số đơn đã huỷ.
  async expireOverdueOwnerApprovals(): Promise<{ expired: number }> {
    const before = new Date(
      Date.now() - OWNER_APPROVAL_WINDOW_HOURS * MS_PER_HOUR,
    );
    const overdue = await bookingRepository.findOverdueAwaitingOwner(
      before,
      EXPIRE_BATCH_LIMIT,
    );

    let expired = 0;
    for (const booking of overdue) {
      try {
        // Giành quyền huỷ trước (chống race với owner approve/reject). Nếu không
        // giành được → đơn đã được xử lý bởi caller khác → bỏ qua.
        const cancelled = await bookingRepository.updateStatusIf(
          booking.id,
          [BookingStatus.AWAITING_OWNER],
          BookingStatus.CANCELLED,
        );
        if (!cancelled) continue;
        await refundService.refundBookingPayment({
          bookingId: booking.id,
          actorId: null,
          reason: "Chủ xe không xác nhận trong thời hạn",
        });
      } catch (error) {
        console.error("Failed to expire awaiting-owner booking", booking.id, error);
        continue;
      }
      expired += 1;
      await notificationService.notify({
        userId: booking.renterId,
        type: "BOOKING",
        title: "Đơn đã huỷ do chủ xe không xác nhận",
        body: "Chủ xe không xác nhận trong thời hạn. Số tiền đã thanh toán sẽ được hoàn lại.",
        payload: { bookingId: booking.id, role: "renter" },
      });
    }
    return { expired };
  },

  // Quét & tự huỷ các đơn PENDING_PAYMENT quá hạn thanh toán (gọi bởi cron).
  // Mỗi đơn: PENDING_PAYMENT → CANCELLED + noti in-app cho renter (fire-and-forget).
  // Lỗi của 1 đơn không được chặn các đơn còn lại. Trả số đơn đã huỷ.
  async expireOverduePayments(): Promise<{ expired: number }> {
    const before = new Date(Date.now() - getPaymentWindowHours() * MS_PER_HOUR);
    const overdue = await bookingRepository.findOverduePendingPayment(
      before,
      EXPIRE_BATCH_LIMIT,
    );

    let expired = 0;
    for (const booking of overdue) {
      try {
        await bookingRepository.updateStatus(
          booking.id,
          BookingStatus.CANCELLED,
        );
      } catch (error) {
        console.error("Failed to expire overdue booking", booking.id, error);
        continue;
      }
      expired += 1;
      await notificationEvents.paymentExpired({
        bookingId: booking.id,
        renterId: booking.renterId,
      });
    }
    return { expired };
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
    // Đơn CONFIRMED = đã thanh toán → phải hoàn tiền (như reject/expire). Đơn
    // PENDING_PAYMENT chưa có tiền nên bỏ qua bước hoàn.
    const wasPaid = booking.status === BookingStatus.CONFIRMED;
    // Compare-and-swap để chống race với owner approve/reject: chỉ caller đổi
    // được trạng thái mới đi tiếp.
    const updated = await bookingRepository.updateStatusIf(
      id,
      CANCELLABLE,
      BookingStatus.CANCELLED,
    );
    if (!updated) {
      throw new AppError(
        409,
        "BOOKING_NOT_CANCELLABLE",
        "Đơn này không thể huỷ ở trạng thái hiện tại",
      );
    }
    if (wasPaid) {
      await refundService.refundBookingPayment({
        bookingId: id,
        actorId: null,
        reason: "Người thuê huỷ đơn đã thanh toán",
      });
    }
    // Báo cho chủ xe rằng người thuê đã huỷ đơn (bỏ qua nếu tự huỷ xe của mình).
    const vehicle = await vehicleRepository.findById(booking.vehicleId);
    if (vehicle && vehicle.ownerId !== renterId) {
      await notificationEvents.bookingCancelled({
        bookingId: updated.id,
        ownerId: vehicle.ownerId,
      });
    }
    return toPublicBooking(updated);
  },
};
