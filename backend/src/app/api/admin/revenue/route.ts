import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { revenueQuerySchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/admin/revenue?months=6 — chuỗi doanh thu theo tháng (ADMIN).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const { months } = revenueQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await adminService.getRevenueSeries(months));
  } catch (error) {
    return toErrorResponse(error);
  }
}
