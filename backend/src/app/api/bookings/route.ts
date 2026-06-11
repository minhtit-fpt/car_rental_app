import { bookingService } from "@/lib/services/booking.service";
import {
  createBookingSchema,
  listBookingsQuerySchema,
} from "@/lib/validators/booking.validator";
import { created, ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireKycVerified } from "@/lib/middleware/kyc.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 15;
const WINDOW_SECONDS = 60;

// POST /api/bookings — tạo đơn đặt (cần KYC VERIFIED).
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireKycVerified(claims);
    await enforceRateLimit(
      `booking-create:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = createBookingSchema.parse(await parseJsonBody(req));
    return created(await bookingService.create(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// GET /api/bookings — danh sách đơn của chính người dùng.
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    const query = listBookingsQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await bookingService.list({ renterId: claims.sub, ...query }));
  } catch (error) {
    return toErrorResponse(error);
  }
}
