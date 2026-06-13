import { authService } from "@/lib/services/auth.service";
import { loginSchema } from "@/lib/validators/auth.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 10;
const WINDOW_SECONDS = 60;

export async function POST(req: Request): Promise<Response> {
  try {
    await enforceRateLimit(
      `login:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = loginSchema.parse(await parseJsonBody(req));
    return ok(await authService.login(input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
