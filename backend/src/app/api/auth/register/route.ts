import { authService } from "@/lib/services/auth.service";
import { registerSchema } from "@/lib/validators/auth.validator";
import { created, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 5;
const WINDOW_SECONDS = 60;

export async function POST(req: Request): Promise<Response> {
  try {
    await enforceRateLimit(
      `register:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = registerSchema.parse(await parseJsonBody(req));
    return created(await authService.register(input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
