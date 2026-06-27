import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { listDisputesSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/admin/disputes?status=OPEN — hàng đợi tranh chấp (ADMIN).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const input = listDisputesSchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await adminService.listDisputes(input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
