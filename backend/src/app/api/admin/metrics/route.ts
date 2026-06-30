import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/admin/metrics — gom mọi aggregation cho dashboard vào 1 object.
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    return ok(await adminService.getMetrics());
  } catch (error) {
    return toErrorResponse(error);
  }
}
