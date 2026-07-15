import { timingSafeEqual } from "node:crypto";
import { bookingService } from "@/lib/services/booking.service";
import { trackingService } from "@/lib/services/tracking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { AppError } from "@/lib/errors/app-error";

export const runtime = "nodejs";

// Header mang secret để scheduler ngoài (cron / Vercel Cron) tự xác thực.
const CRON_SECRET_HEADER = "x-cron-secret";

// So sánh constant-time để tránh timing attack khi đối chiếu secret.
function secretsMatch(provided: string, expected: string): boolean {
  const a = Buffer.from(provided);
  const b = Buffer.from(expected);
  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

function assertCronAuthorized(req: Request): void {
  const expected = process.env.CRON_SECRET;
  // Thiếu cấu hình → coi như endpoint chưa bật, không cho chạy.
  if (!expected) {
    throw new AppError(503, "CRON_NOT_CONFIGURED", "Cron chưa được cấu hình");
  }
  const provided = req.headers.get(CRON_SECRET_HEADER);
  if (!provided || !secretsMatch(provided, expected)) {
    throw new AppError(401, "UNAUTHORIZED", "Không có quyền truy cập");
  }
}

// POST /api/cron/payment-reminders — hai việc định kỳ, bảo vệ bằng header
// `x-cron-secret`, gọi bởi scheduler ngoài (cron / Vercel Cron):
//  1) Huỷ đơn PENDING_PAYMENT quá hạn thanh toán (không có tiền).
//  2) Huỷ + hoàn tiền đơn AWAITING_OWNER quá hạn chủ xe xác nhận (24h).
export async function POST(req: Request): Promise<Response> {
  try {
    assertCronAuthorized(req);
    const [payments, ownerApprovals, completed, tracking] = await Promise.all([
      bookingService.expireOverduePayments(),
      bookingService.expireOverdueOwnerApprovals(),
      bookingService.completeOverdueBookings(),
      trackingService.pruneOldLocations(),
    ]);
    return ok({
      expiredPayments: payments.expired,
      expiredOwnerApprovals: ownerApprovals.expired,
      completedBookings: completed.completed,
      prunedLocations: tracking.pruned,
    });
  } catch (error) {
    return toErrorResponse(error);
  }
}
