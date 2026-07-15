import { PaymentStatus } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { adminRepository } from "@/lib/repositories/admin.repository";

// Hoàn tiền cho 1 booking — CHỈ đổi DB (Payment REFUNDED) + ghi AuditLog, KHÔNG
// gọi cổng thanh toán thật. Dùng chung cho:
//  - ADMIN xử lý tranh chấp (actorId = adminId, amount có thể một phần)
//  - Hệ thống tự hoàn khi owner từ chối / hết hạn duyệt (actorId = null, full)
// Không tự gửi noti — caller quyết định thông điệp phù hợp ngữ cảnh.

export interface RefundResult {
  bookingId: string;
  renterId: string;
  status: PaymentStatus;
  amount: number;
  // false = đã được hoàn trước đó bởi caller khác (race). Caller nên bỏ qua
  // gửi notification/đếm để tránh trùng.
  refunded: boolean;
}

export const refundService = {
  async refundBookingPayment(params: {
    bookingId: string;
    actorId: string | null;
    reason: string;
    // undefined = hoàn toàn bộ số đã trả (dùng cho auto-refund hệ thống).
    amount?: number;
  }): Promise<RefundResult> {
    const booking = await adminRepository.findBookingForRefund(params.bookingId);
    if (!booking) {
      throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn");
    }
    if (!booking.payment) {
      throw new AppError(409, "NO_PAYMENT", "Đơn chưa có thanh toán");
    }
    if (booking.payment.status !== PaymentStatus.PAID) {
      throw new AppError(
        409,
        "PAYMENT_NOT_REFUNDABLE",
        "Chỉ hoàn được thanh toán đã thanh toán thành công",
      );
    }
    const paidAmount = booking.payment.amount.toNumber();
    const amount = params.amount ?? paidAmount;
    if (amount > paidAmount) {
      throw new AppError(
        400,
        "INVALID_REFUND_AMOUNT",
        "Số tiền hoàn vượt quá số tiền đã thanh toán",
      );
    }

    const updated = await adminRepository.refundPayment(
      params.bookingId,
      amount,
      params.actorId,
      params.reason,
    );
    return {
      bookingId: params.bookingId,
      renterId: booking.renterId,
      status: updated.status,
      amount,
      refunded: updated.refunded,
    };
  },
};
