import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// GET /api/admin/bookings/:id — chi tiết đơn (payment/contract/inspection/dispute).
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    return ok(await adminService.getBookingDetail(params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
