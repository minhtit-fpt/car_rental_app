import { kycService } from "@/lib/services/kyc.service";
import { uploadUrlSchema } from "@/lib/validators/kyc.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 20;
const WINDOW_SECONDS = 60;

export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `kyc-upload-url:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = uploadUrlSchema.parse(await parseJsonBody(req));
    return ok(await kycService.createUploadUrl(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
