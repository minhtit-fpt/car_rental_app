import { inspectionService } from "@/lib/services/inspection.service";
import { submitInspectionSchema } from "@/lib/validators/inspection.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// PUT /api/bookings/:id/inspections — lưu bộ ảnh đã upload cho một phase
// (CHECKIN | CHECKOUT). Body: { phase, photoKeys[] }.
export async function PUT(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `inspection-submit:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = submitInspectionSchema.parse(await req.json());
    return ok(await inspectionService.submit(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
