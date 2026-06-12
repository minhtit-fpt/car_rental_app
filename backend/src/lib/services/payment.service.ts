import {
  BookingStatus,
  PaymentMethod,
  PaymentStatus,
  type Booking,
  type Payment,
} from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { paymentRepository } from "@/lib/repositories/payment.repository";
import { bookingService, type PublicBooking } from "@/lib/services/booking.service";
import { paymentProvider } from "@/lib/payments";
import type {
  ConfirmPaymentInput,
  CreatePaymentInput,
} from "@/lib/validators/payment.validator";

export interface PublicPayment {
  id: string;
  bookingId: string;
  method: PaymentMethod;
  status: PaymentStatus;
  amount: number;
  gatewayRef: string | null;
  paidAt: Date | null;
  createdAt: Date;
}

export interface CreatePaymentResult {
  payment: PublicPayment;
  payUrl: string;
}

export interface ConfirmPaymentResult {
  payment: PublicPayment;
  booking: PublicBooking | null;
}

function toPublicPayment(p: Payment): PublicPayment {
  return {
    id: p.id,
    bookingId: p.bookingId,
    method: p.method,
    status: p.status,
    amount: Number(p.amount),
    gatewayRef: p.gatewayRef,
    paidAt: p.paidAt,
    createdAt: p.createdAt,
  };
}

// Nạp booking + kiểm tra quyền sở hữu của người gọi.
async function loadOwnedBooking(
  bookingId: string,
  renterId: string,
): Promise<Booking> {
  const booking = await bookingRepository.findById(bookingId);
  if (!booking) {
    throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
  }
  if (booking.renterId !== renterId) {
    throw new AppError(403, "FORBIDDEN", "Đây không phải đơn của bạn");
  }
  return booking;
}

// Nạp payment + kiểm tra người gọi sở hữu booking phía sau.
async function loadOwnedPayment(
  paymentId: string,
  renterId: string,
): Promise<{ payment: Payment; booking: Booking }> {
  const payment = await paymentRepository.findById(paymentId);
  if (!payment) {
    throw new AppError(404, "PAYMENT_NOT_FOUND", "Không tìm thấy giao dịch");
  }
  const booking = await loadOwnedBooking(payment.bookingId, renterId);
  return { payment, booking };
}

export const paymentService = {
  // Tạo (hoặc tái sử dụng) phiên thanh toán cho đơn đang chờ thanh toán.
  async create(
    renterId: string,
    input: CreatePaymentInput,
  ): Promise<CreatePaymentResult> {
    const booking = await loadOwnedBooking(input.bookingId, renterId);
    if (booking.status !== BookingStatus.PENDING_PAYMENT) {
      throw new AppError(
        409,
        "PAYMENT_NOT_ALLOWED",
        "Đơn không ở trạng thái chờ thanh toán",
      );
    }

    const existing = await paymentRepository.findByBookingId(booking.id);
    if (existing?.status === PaymentStatus.PAID) {
      throw new AppError(409, "ALREADY_PAID", "Đơn này đã được thanh toán");
    }

    const amount = Number(booking.totalPrice);
    const { payUrl, gatewayRef } = await paymentProvider.createPayment({
      reference: existing?.id ?? booking.id,
      amount,
      orderInfo: `Thanh toan don ${booking.id}`,
    });

    const payment = existing
      ? await paymentRepository.updateStatus(existing.id, {
          status: PaymentStatus.PENDING,
          gatewayRef,
        })
      : await paymentRepository.create({
          bookingId: booking.id,
          method: PaymentMethod.VNPAY,
          amount,
          gatewayRef,
        });

    return { payment: toPublicPayment(payment), payUrl };
  },

  async getById(renterId: string, paymentId: string): Promise<PublicPayment> {
    const { payment } = await loadOwnedPayment(paymentId, renterId);
    return toPublicPayment(payment);
  },

  // Mô phỏng callback từ cổng (mock-first). Thành công → Payment PAID +
  // Booking CONFIRMED; thất bại → Payment FAILED, Booking giữ nguyên.
  async confirm(
    renterId: string,
    paymentId: string,
    input: ConfirmPaymentInput,
  ): Promise<ConfirmPaymentResult> {
    const { payment } = await loadOwnedPayment(paymentId, renterId);

    if (payment.status === PaymentStatus.PAID) {
      throw new AppError(409, "ALREADY_PAID", "Giao dịch đã hoàn tất");
    }

    const verified = await paymentProvider.verifyCallback({
      reference: payment.id,
      gatewayRef: payment.gatewayRef ?? "",
      success: input.success,
    });

    if (!verified) {
      const failed = await paymentRepository.updateStatus(payment.id, {
        status: PaymentStatus.FAILED,
      });
      return { payment: toPublicPayment(failed), booking: null };
    }

    // Xác nhận đơn TRƯỚC khi đánh dấu đã trả tiền: nếu vướng trùng giờ thì
    // không thu tiền (giữ payment PENDING để client thử lại / huỷ).
    const booking = await bookingService.confirmAfterPayment(payment.bookingId);

    const paid = await paymentRepository.updateStatus(payment.id, {
      status: PaymentStatus.PAID,
      paidAt: new Date(),
    });

    return { payment: toPublicPayment(paid), booking };
  },
};
