import { trackingService } from "@/lib/services/tracking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

// GET /api/tracking/active — vị trí mới nhất mọi xe đang trong chuyến (map admin).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await trackingService.listActive(claims));
  } catch (error) {
    return toErrorResponse(error);
  }
}
