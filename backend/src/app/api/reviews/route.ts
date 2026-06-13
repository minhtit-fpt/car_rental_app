import { reviewService } from "@/lib/services/review.service";
import { createReviewSchema } from "@/lib/validators/review.validator";
import { created, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 10;
const WINDOW_SECONDS = 60;

// POST /api/reviews — đánh giá đối tác trong một đơn (renter ↔ chủ xe).
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `review-create:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = createReviewSchema.parse(await parseJsonBody(req));
    return created(await reviewService.create(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
