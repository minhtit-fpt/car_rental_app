import { UserRole } from "@prisma/client";
import { ownerService } from "@/lib/services/owner.service";
import { ownerRevenueQuerySchema } from "@/lib/validators/owner.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/owner/revenue — tổng quan doanh thu của chủ xe (OWNER).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.OWNER);
    const { months } = ownerRevenueQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await ownerService.getRevenue(claims.sub, months));
  } catch (error) {
    return toErrorResponse(error);
  }
}
