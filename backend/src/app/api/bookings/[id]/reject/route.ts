import { UserRole } from "@prisma/client";
import { bookingService } from "@/lib/services/booking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// POST /api/bookings/:id/reject — chủ xe từ chối yêu cầu đặt (OWNER).
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.OWNER);
    await enforceRateLimit(
      `booking-reject:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await bookingService.reject(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
