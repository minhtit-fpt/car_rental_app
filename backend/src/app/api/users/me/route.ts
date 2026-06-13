import { userService } from "@/lib/services/user.service";
import { updateProfileSchema } from "@/lib/validators/user.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 10;
const WINDOW_SECONDS = 60;

// PATCH /api/users/me — cập nhật hồ sơ của chính mình (MVP: email).
export async function PATCH(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `profile-update:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = updateProfileSchema.parse(await parseJsonBody(req));
    return ok(await userService.updateProfile(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
