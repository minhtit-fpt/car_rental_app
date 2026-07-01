import { NotificationType } from "@prisma/client";
import { notificationService } from "@/lib/services/notification.service";
import { emailService } from "@/lib/services/email.service";

// Phát thông báo theo sự kiện nghiệp vụ (đặt xe / thanh toán).
// Tất cả dùng `safeCreate` — lỗi noti KHÔNG được làm hỏng luồng chính.

interface BookingParties {
  bookingId: string;
  renterId: string;
  ownerId: string;
}

// Tiêu đề/nội dung email gửi renter khi thanh toán thành công.
const PAYMENT_EMAIL_SUBJECT = "Thanh toán thành công — RideVN";
const PAYMENT_EMAIL_BODY =
  "Chuyến đi của bạn đã được xác nhận. Cảm ơn bạn đã sử dụng RideVN!";

interface RenterEvent {
  bookingId: string;
  renterId: string;
}

interface OwnerEvent {
  bookingId: string;
  ownerId: string;
}

export const notificationEvents = {
  // Renter vừa tạo đơn (chờ thanh toán) + owner nhận yêu cầu mới.
  async bookingCreated(p: BookingParties): Promise<void> {
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Đặt xe thành công",
        body: "Đơn của bạn đã được tạo, vui lòng hoàn tất thanh toán.",
        payload: { bookingId: p.bookingId },
      }),
      notificationService.safeCreate({
        userId: p.ownerId,
        type: NotificationType.BOOKING,
        title: "Có yêu cầu thuê xe mới",
        body: "Một khách vừa gửi yêu cầu thuê xe của bạn.",
        payload: { bookingId: p.bookingId },
      }),
    ]);
  },

  // Owner phê duyệt đơn.
  async bookingApproved(p: RenterEvent): Promise<void> {
    await notificationService.safeCreate({
      userId: p.renterId,
      type: NotificationType.BOOKING,
      title: "Chủ xe đã xác nhận",
      body: "Yêu cầu thuê xe của bạn đã được chủ xe chấp nhận.",
      payload: { bookingId: p.bookingId },
    });
  },

  // Owner từ chối đơn.
  async bookingRejected(p: RenterEvent): Promise<void> {
    await notificationService.safeCreate({
      userId: p.renterId,
      type: NotificationType.BOOKING,
      title: "Yêu cầu bị từ chối",
      body: "Rất tiếc, chủ xe đã từ chối yêu cầu thuê xe của bạn.",
      payload: { bookingId: p.bookingId },
    });
  },

  // Thanh toán thành công (đơn chuyển CONFIRMED). Ngoài noti in-app, gửi email
  // cho renter nếu có địa chỉ email (fire-and-forget, không chặn luồng).
  async paymentConfirmed(
    p: BookingParties & { renterEmail?: string | null },
  ): Promise<void> {
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.PAYMENT,
        title: "Thanh toán thành công",
        body: "Chuyến đi của bạn đã được xác nhận. Chúc bạn lên đường vui vẻ!",
        payload: { bookingId: p.bookingId },
      }),
      notificationService.safeCreate({
        userId: p.ownerId,
        type: NotificationType.PAYMENT,
        title: "Đơn đã được thanh toán",
        body: "Khách đã thanh toán cho đơn thuê xe của bạn.",
        payload: { bookingId: p.bookingId },
      }),
      p.renterEmail
        ? emailService.sendNotificationEmail(
            p.renterEmail,
            PAYMENT_EMAIL_SUBJECT,
            PAYMENT_EMAIL_BODY,
          )
        : Promise.resolve(),
    ]);
  },

  // Đơn tự huỷ do quá hạn thanh toán (cron). Chỉ noti in-app cho renter —
  // KHÔNG gửi email (chốt: hết hạn thanh toán thì chỉ báo trong app).
  async paymentExpired(p: RenterEvent): Promise<void> {
    await notificationService.safeCreate({
      userId: p.renterId,
      type: NotificationType.PAYMENT,
      title: "Đơn đã bị huỷ do quá hạn thanh toán",
      body: "Bạn chưa hoàn tất thanh toán trong thời gian quy định nên đơn đã tự động huỷ.",
      payload: { bookingId: p.bookingId },
    });
  },

  // VLM phát hiện hư hỏng tại 1 lượt kiểm tra (nhận/trả) — báo CẢ renter và owner
  // để ghi nhận tình trạng xe lúc giao/trả (chứng cứ cho phương án đền bù sau).
  async inspectionDamageFound(p: {
    bookingId: string;
    renterId: string;
    ownerId: string;
    phase: "CHECKIN" | "CHECKOUT";
    summary: string;
  }): Promise<void> {
    const when = p.phase === "CHECKIN" ? "khi nhận xe" : "khi trả xe";
    const summary = p.summary.trim();
    const body = summary
      ? `AI phát hiện hư hỏng ${when}: ${summary}`
      : `AI phát hiện hư hỏng ${when}. Vui lòng kiểm tra ảnh kiểm tra xe.`;
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Phát hiện hư hỏng xe",
        body,
        payload: { bookingId: p.bookingId },
      }),
      notificationService.safeCreate({
        userId: p.ownerId,
        type: NotificationType.BOOKING,
        title: "Phát hiện hư hỏng xe",
        body,
        payload: { bookingId: p.bookingId },
      }),
    ]);
  },

  // Renter huỷ đơn — báo cho owner.
  async bookingCancelled(p: OwnerEvent): Promise<void> {
    await notificationService.safeCreate({
      userId: p.ownerId,
      type: NotificationType.BOOKING,
      title: "Khách đã huỷ đơn",
      body: "Một đơn thuê xe của bạn vừa bị khách huỷ.",
      payload: { bookingId: p.bookingId },
    });
  },
};
