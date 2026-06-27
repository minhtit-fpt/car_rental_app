import { communityService } from "@/lib/services/community.service";
import {
  createStorySchema,
  listStoriesQuerySchema,
} from "@/lib/validators/community.validator";
import { created, ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 10;
const WINDOW_SECONDS = 60;

// GET /api/community — feed các câu chuyện chuyến đi (mới nhất trước).
export async function GET(req: Request): Promise<Response> {
  try {
    await requireAuth(req);
    const query = listStoriesQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await communityService.list(query));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// POST /api/community — đăng một câu chuyện chuyến đi.
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `community-create:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = createStorySchema.parse(await parseJsonBody(req));
    return created(await communityService.create(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
