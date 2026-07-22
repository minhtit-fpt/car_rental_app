import { NotificationType } from "@prisma/client";
import { notificationService } from "@/lib/services/notification.service";
import {
  emailService,
  type BookingEmailDetails,
} from "@/lib/services/email.service";

// Phát thông báo theo sự kiện nghiệp vụ (đặt xe / thanh toán).
// Tất cả dùng `safeCreate` — lỗi noti KHÔNG được làm hỏng luồng chính.
// Email cũng fire-and-forget (emailService không bao giờ ném lỗi).

interface BookingParties {
  bookingId: string;
  renterId: string;
  ownerId: string;
}

interface RenterEvent {
  bookingId: string;
  renterId: string;
}

interface OwnerEvent {
  bookingId: string;
  ownerId: string;
}

// Thông tin email đính kèm sự kiện — có đủ (địa chỉ + chi tiết đơn) mới gửi.
interface EmailInfo {
  renterEmail?: string | null;
  ownerEmail?: string | null;
  emailDetails?: BookingEmailDetails;
}

function sendIfPossible(
  to: string | null | undefined,
  subject: string,
  intro: string,
  details: BookingEmailDetails | undefined,
): Promise<boolean> {
  if (!to || !details) return Promise.resolve(false);
  return emailService.sendBookingEmail(to, subject, intro, details);
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

  // Owner phê duyệt đơn — noti in-app + email chi tiết cho renter.
  async bookingApproved(
    p: RenterEvent & { vehicleTitle: string } & EmailInfo,
  ): Promise<void> {
    const body = `${p.vehicleTitle} đã được chủ xe xác nhận. Chúc bạn có chuyến đi vui vẻ!`;
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Đơn đặt đã được xác nhận",
        body,
        payload: { bookingId: p.bookingId, role: "renter" },
      }),
      sendIfPossible(
        p.renterEmail,
        "Chủ xe đã xác nhận đơn — RideVN",
        body,
        p.emailDetails,
      ),
    ]);
  },

  // Owner từ chối đơn (đã thanh toán → kèm hoàn tiền) — noti + email cho renter.
  async bookingRejected(
    p: RenterEvent & { vehicleTitle: string } & EmailInfo,
  ): Promise<void> {
    const body = `${p.vehicleTitle} đã bị chủ xe từ chối. Số tiền đã thanh toán sẽ được hoàn lại.`;
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Đơn đặt bị từ chối",
        body,
        payload: { bookingId: p.bookingId, role: "renter" },
      }),
      sendIfPossible(
        p.renterEmail,
        "Đơn bị từ chối — hoàn tiền — RideVN",
        body,
        p.emailDetails,
      ),
    ]);
  },

  // Khách đã thanh toán → đơn chuyển AWAITING_OWNER (CHƯA confirmed). Báo renter
  // "đã thanh toán, chờ chủ xe xác nhận" + owner "khách đã thanh toán, hãy xác
  // nhận". Ngoài noti in-app, gửi email chi tiết cho cả renter và owner.
  async paymentAwaitingOwner(p: BookingParties & EmailInfo): Promise<void> {
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
      sendIfPossible(
        p.renterEmail,
        "Thanh toán thành công — RideVN",
        "Đơn của bạn đã được thanh toán và đang chờ chủ xe xác nhận. Cảm ơn bạn đã sử dụng RideVN!",
        p.emailDetails,
      ),
      sendIfPossible(
        p.ownerEmail,
        "Khách đã thanh toán — chờ bạn xác nhận — RideVN",
        "Một khách đã thanh toán đơn thuê xe của bạn. Vui lòng vào ứng dụng xác nhận đơn trong thời hạn để tránh đơn tự huỷ.",
        p.emailDetails,
      ),
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

  // Renter huỷ đơn — báo cho owner (noti + email). Nếu đơn đã thanh toán và
  // được hoàn tiền, gửi thêm email xác nhận hoàn tiền cho renter.
  // `ownerId = null` khi renter tự huỷ xe của chính mình (không báo owner).
  async bookingCancelled(
    p: Omit<OwnerEvent, "ownerId"> & { ownerId: string | null } & EmailInfo & {
        refunded?: boolean;
      },
  ): Promise<void> {
    await Promise.all([
      p.ownerId
        ? notificationService.safeCreate({
            userId: p.ownerId,
            type: NotificationType.BOOKING,
            title: "Khách đã huỷ đơn",
            body: "Một đơn thuê xe của bạn vừa bị khách huỷ.",
            payload: { bookingId: p.bookingId, role: "owner" },
          })
        : Promise.resolve(),
      p.ownerId
        ? sendIfPossible(
            p.ownerEmail,
            "Khách đã huỷ đơn — RideVN",
            "Một đơn thuê xe của bạn vừa bị khách huỷ. Xem chi tiết bên dưới.",
            p.emailDetails,
          )
        : Promise.resolve(false),
      p.refunded
        ? sendIfPossible(
            p.renterEmail,
            "Xác nhận huỷ đơn — hoàn tiền — RideVN",
            "Đơn của bạn đã được huỷ. Số tiền đã thanh toán sẽ được hoàn lại.",
            p.emailDetails,
          )
        : Promise.resolve(false),
    ]);
  },

  // Cron tự huỷ đơn do chủ xe không xác nhận trong thời hạn — noti + email hoàn
  // tiền cho renter.
  async ownerApprovalExpired(p: RenterEvent & EmailInfo): Promise<void> {
    const body =
      "Chủ xe không xác nhận trong thời hạn. Số tiền đã thanh toán sẽ được hoàn lại.";
    await Promise.all([
      notificationService.safeCreate({
        userId: p.renterId,
        type: NotificationType.BOOKING,
        title: "Đơn đã huỷ do chủ xe không xác nhận",
        body,
        payload: { bookingId: p.bookingId, role: "renter" },
      }),
      sendIfPossible(
        p.renterEmail,
        "Đơn đã huỷ — hoàn tiền — RideVN",
        body,
        p.emailDetails,
      ),
    ]);
  },
};
