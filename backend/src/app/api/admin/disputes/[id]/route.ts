import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { resolveDisputeSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// PATCH /api/admin/disputes/:id — ADMIN giải quyết/bác bỏ tranh chấp.
export async function PATCH(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const input = resolveDisputeSchema.parse(await parseJsonBody(req));
    return ok(await adminService.resolveDispute(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
