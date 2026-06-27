import { notificationService } from "@/lib/services/notification.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

// POST /api/notifications/read-all — đánh dấu tất cả thông báo là đã đọc.
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await notificationService.markAllRead(claims.sub));
  } catch (error) {
    return toErrorResponse(error);
  }
}
