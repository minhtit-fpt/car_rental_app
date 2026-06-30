import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { listVehiclesSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/admin/vehicles — hàng đợi duyệt xe (mặc định PENDING).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const params = Object.fromEntries(new URL(req.url).searchParams);
    const input = listVehiclesSchema.parse(params);
    return ok(await adminService.listVehicles(input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
