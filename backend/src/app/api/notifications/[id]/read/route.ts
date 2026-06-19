import { notificationService } from "@/lib/services/notification.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// POST /api/notifications/:id/read — đánh dấu một thông báo là đã đọc.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await notificationService.markRead(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
