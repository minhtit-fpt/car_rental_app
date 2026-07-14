import { trackingService } from "@/lib/services/tracking.service";
import { latestQuerySchema } from "@/lib/validators/tracking.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

// FE poll ~3s (≈20/phút); nới gấp đôi để chịu jitter nhưng vẫn chặn hammer.
const READ_RATE_LIMIT = 40;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { vehicleId: string };
}

// GET /api/tracking/:vehicleId/latest?trail=N — vị trí realtime (điểm mới nhất
// + N điểm trail). Quyền: admin / chủ xe / người thuê của chuyến đang chạy.
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `tracking-read:${claims.sub}:${params.vehicleId}`,
      READ_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const query = Object.fromEntries(new URL(req.url).searchParams);
    const { trail } = latestQuerySchema.parse(query);
    return ok(
      await trackingService.getSnapshot(claims, params.vehicleId, trail),
    );
  } catch (error) {
    return toErrorResponse(error);
  }
}
