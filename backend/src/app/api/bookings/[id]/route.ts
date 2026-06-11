import { bookingService } from "@/lib/services/booking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// GET /api/bookings/:id — chi tiết đơn (chỉ chủ đơn).
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await bookingService.getById(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
