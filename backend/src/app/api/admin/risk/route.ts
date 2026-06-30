import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/admin/risk — hàng đợi tài khoản bị cờ rủi ro (rule-engine, explainable).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    return ok(await adminService.listRiskFlags());
  } catch (error) {
    return toErrorResponse(error);
  }
}
