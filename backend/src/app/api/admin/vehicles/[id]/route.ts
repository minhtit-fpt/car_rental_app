import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { reviewVehicleSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// PATCH /api/admin/vehicles/:id — ADMIN duyệt/từ chối xe.
export async function PATCH(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const input = reviewVehicleSchema.parse(await parseJsonBody(req));
    return ok(await adminService.reviewVehicle(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
