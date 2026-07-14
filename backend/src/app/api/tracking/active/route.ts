import { trackingService } from "@/lib/services/tracking.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

// Map admin poll ~3s; nới gấp đôi (≈40/phút) nhưng chặn hammer query DISTINCT ON.
const ACTIVE_RATE_LIMIT = 40;
const WINDOW_SECONDS = 60;

// GET /api/tracking/active — vị trí mới nhất mọi xe đang trong chuyến (map admin).
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `tracking-active:${claims.sub}`,
      ACTIVE_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await trackingService.listActive(claims));
  } catch (error) {
    return toErrorResponse(error);
  }
}
