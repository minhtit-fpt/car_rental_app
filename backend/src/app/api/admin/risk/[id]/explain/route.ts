import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// POST /api/admin/risk/:id/explain — AI viết lời giải thích vì sao user bị cờ
// rủi ro, dựa trên các rule đã kích hoạt. Advisory; offline → explanation null.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    return ok(await adminService.explainRiskFlag(params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
