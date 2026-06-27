import { notificationService } from "@/lib/services/notification.service";
import { listNotificationsQuerySchema } from "@/lib/validators/notification.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

// GET /api/notifications — danh sách thông báo của người dùng + số chưa đọc.
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    const query = listNotificationsQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await notificationService.list(claims.sub, query));
  } catch (error) {
    return toErrorResponse(error);
  }
}
