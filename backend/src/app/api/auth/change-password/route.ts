import { authService } from "@/lib/services/auth.service";
import { changePasswordSchema } from "@/lib/validators/auth.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

// Đổi mật khẩu là endpoint nhạy cảm → siết rate limit chặt hơn login.
const RATE_LIMIT = 5;
const WINDOW_SECONDS = 60;

// PATCH /api/auth/change-password — đổi mật khẩu của chính mình.
export async function PATCH(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `change-password:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = changePasswordSchema.parse(await parseJsonBody(req));
    await authService.changePassword(claims.sub, input);
    return ok({ updated: true });
  } catch (error) {
    return toErrorResponse(error);
  }
}
