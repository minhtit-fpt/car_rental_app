import { timingSafeEqual } from "node:crypto";
import { bookingService } from "@/lib/services/booking.service";
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

// POST /api/cron/payment-reminders — tự huỷ các đơn PENDING_PAYMENT quá hạn
// thanh toán + gửi noti in-app cho renter. Bảo vệ bằng header `x-cron-secret`.
// Được gọi định kỳ bởi scheduler ngoài (cron / Vercel Cron).
export async function POST(req: Request): Promise<Response> {
  try {
    assertCronAuthorized(req);
    return ok(await bookingService.expireOverduePayments());
  } catch (error) {
    return toErrorResponse(error);
  }
}
