import { UserRole } from "@prisma/client";
import { adminService } from "@/lib/services/admin.service";
import { listBookingsSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// GET /api/admin/bookings — danh sách đơn (lọc trạng thái + khoảng ngày).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const params = Object.fromEntries(new URL(req.url).searchParams);
    const input = listBookingsSchema.parse(params);
    return ok(await adminService.listBookings(input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
