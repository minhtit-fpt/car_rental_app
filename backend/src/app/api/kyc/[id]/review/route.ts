import { UserRole } from "@prisma/client";
import { kycService } from "@/lib/services/kyc.service";
import { reviewKycSchema } from "@/lib/validators/kyc.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    await enforceRateLimit(
      `kyc-review:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = reviewKycSchema.parse(await parseJsonBody(req));
    return ok(await kycService.review(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
