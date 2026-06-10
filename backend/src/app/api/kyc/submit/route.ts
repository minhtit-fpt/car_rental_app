import { kycService } from "@/lib/services/kyc.service";
import { submitKycSchema } from "@/lib/validators/kyc.validator";
import { created, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 10;
const WINDOW_SECONDS = 60;

export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `kyc-submit:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = submitKycSchema.parse(await parseJsonBody(req));
    return created(await kycService.submit(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
