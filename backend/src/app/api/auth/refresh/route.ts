import { authService } from "@/lib/services/auth.service";
import { refreshSchema } from "@/lib/validators/auth.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 20;
const WINDOW_SECONDS = 60;

export async function POST(req: Request): Promise<Response> {
  try {
    await enforceRateLimit(
      `refresh:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const { refreshToken } = refreshSchema.parse(await parseJsonBody(req));
    return ok({ tokens: await authService.refresh(refreshToken) });
  } catch (error) {
    return toErrorResponse(error);
  }
}
