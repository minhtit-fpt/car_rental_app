import { paymentService } from "@/lib/services/payment.service";
import { confirmPaymentSchema } from "@/lib/validators/payment.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 15;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// POST /api/payments/:id/confirm — mô phỏng callback cổng (mock-first).
// Thành công → đơn chuyển CONFIRMED. Adapter thật sẽ nhận IPN có chữ ký.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `payment-confirm:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = confirmPaymentSchema.parse(await parseJsonBody(req));
    return ok(await paymentService.confirm(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
