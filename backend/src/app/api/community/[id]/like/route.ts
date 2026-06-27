import { communityService } from "@/lib/services/community.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// POST /api/community/:id/like — tăng lượt thích cho một câu chuyện.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    await requireAuth(req);
    await enforceRateLimit(
      `community-like:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await communityService.like(params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
