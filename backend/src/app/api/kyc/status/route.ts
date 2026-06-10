import { kycService } from "@/lib/services/kyc.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `kyc-status:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await kycService.getStatus(claims.sub));
  } catch (error) {
    return toErrorResponse(error);
  }
}
