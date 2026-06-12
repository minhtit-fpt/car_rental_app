import { paymentService } from "@/lib/services/payment.service";
import { createPaymentSchema } from "@/lib/validators/payment.validator";
import { created, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireKycVerified } from "@/lib/middleware/kyc.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 15;
const WINDOW_SECONDS = 60;

// POST /api/payments — tạo phiên thanh toán cho đơn (cần KYC VERIFIED).
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireKycVerified(claims);
    await enforceRateLimit(
      `payment-create:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = createPaymentSchema.parse(await parseJsonBody(req));
    return created(await paymentService.create(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
