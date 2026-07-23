import { UserRole } from "@prisma/client";
import { bookingService } from "@/lib/services/booking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// GET /api/owner/bookings/:id — chi tiết 1 đơn cho chủ xe (vd mở từ thông báo).
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.OWNER);
    return ok(await bookingService.getByIdForOwner(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
