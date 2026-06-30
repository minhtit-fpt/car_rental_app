import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { refundPaymentSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// POST /api/admin/bookings/:id/refund — ADMIN hoàn tiền (đánh dấu REFUNDED + audit).
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const input = refundPaymentSchema.parse(await parseJsonBody(req));
    return ok(await adminService.refundPayment(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
