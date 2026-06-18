import { UserRole } from "@prisma/client";
import { bookingService } from "@/lib/services/booking.service";
import { listBookingsQuerySchema } from "@/lib/validators/booking.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/owner/bookings — đơn đặt trên các xe của chủ xe (OWNER).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.OWNER);
    const query = listBookingsQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(
      await bookingService.listForOwner({ ownerId: claims.sub, ...query }),
    );
  } catch (error) {
    return toErrorResponse(error);
  }
}
