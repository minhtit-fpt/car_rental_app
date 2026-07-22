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
  "Đơn của bạn đã được thanh toán và đang chờ chủ xe xác nhận. Cảm ơn bạn đã sử dụng RideVN!";

interface RenterEvent {
  bookingId: string;
  renterId: string;
}

interface OwnerEvent {
  bookingId: string;
  ownerId: string;
}

export const notificationEvents = {
  // Renter vừa tạo đơn (chờ thanh toán). Luồng pay-first: KHÔNG báo owner ở đây —
  // owner chỉ được báo sau khi khách thanh toán (xem `paymentAwaitingOwner`), tránh
  // đơn chưa trả tiền hiện lên như "yêu cầu mới" phía chủ xe.
  async bookingCreated(p: RenterEvent): Promise<void> {
    await notificationService.safeCreate({
      userId: p.renterId,
      type: NotificationType.BOOKING,
      title: "Đã tạo đơn, vui lòng thanh toán",
      body: "Đơn của bạn đã được tạo. Hãy hoàn tất thanh toán để giữ chỗ.",
      payload: { bookingId: p.bookingId },
    });
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

  // Khách đã thanh toán → đơn chuyển AWAITING_OWNER (CHƯA confirmed). Báo renter
  // "đã thanh toán, chờ chủ xe xác nhận" + owner "khách đã thanh toán, hãy xác
  // nhận". Ngoài noti in-app, gửi email cho renter nếu có (fire-and-forget).
  async paymentAwaitingOwner(
    p: BookingParties & { renterEmail?: string | null },
  ): Promise<void> {
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.PAYMENT,
        title: "Thanh toán thành công",
        body: "Đơn đã được thanh toán, đang chờ chủ xe xác nhận.",
        payload: { bookingId: p.bookingId },
      }),
      notificationService.safeCreate({
        userId: p.ownerId,
        type: NotificationType.PAYMENT,
        title: "Khách đã thanh toán, chờ bạn xác nhận",
        body: "Một khách đã thanh toán. Vui lòng xác nhận để hoàn tất đơn.",
        payload: { bookingId: p.bookingId, role: "owner" },
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

  // Hết ngày thuê, xe coi như đã trả → đơn tự chuyển COMPLETED (cron). Báo cả
  // renter và owner rằng chuyến đã hoàn thành.
  async bookingCompleted(p: BookingParties): Promise<void> {
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Chuyến đi đã hoàn thành",
        body: "Đã hết thời gian thuê. Chuyến của bạn được đánh dấu hoàn thành. Đừng quên đánh giá nhé!",
        payload: { bookingId: p.bookingId },
      }),
      notificationService.safeCreate({
        userId: p.ownerId,
        type: NotificationType.BOOKING,
        title: "Chuyến đi đã hoàn thành",
        body: "Một chuyến thuê xe của bạn đã kết thúc và được đánh dấu hoàn thành.",
        payload: { bookingId: p.bookingId, role: "owner" },
      }),
    ]);
  },

  // Hết ngày thuê nhưng xe đang trong chuyến (IN_PROGRESS) — nhắc renter trả xe,
  // báo owner xe quá hạn chưa trả.
  async bookingReturnOverdue(p: BookingParties): Promise<void> {
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Đã đến hạn trả xe",
        body: "Đã hết thời gian thuê. Vui lòng trả xe sớm để tránh phát sinh phí quá hạn.",
        payload: { bookingId: p.bookingId },
      }),
      notificationService.safeCreate({
        userId: p.ownerId,
        type: NotificationType.BOOKING,
        title: "Xe quá hạn chưa được trả",
        body: "Một chuyến thuê đã hết hạn nhưng khách chưa trả xe. Vui lòng liên hệ khách thuê.",
        payload: { bookingId: p.bookingId, role: "owner" },
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
      payload: { bookingId: p.bookingId, role: "owner" },
    });
  },
};
