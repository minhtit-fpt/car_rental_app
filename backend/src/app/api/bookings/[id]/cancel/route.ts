import { bookingService } from "@/lib/services/booking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 15;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// POST /api/bookings/:id/cancel — chủ đơn huỷ đơn.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `booking-cancel:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await bookingService.cancel(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
