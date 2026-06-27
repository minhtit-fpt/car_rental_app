import { inspectionService } from "@/lib/services/inspection.service";
import { inspectionUploadUrlSchema } from "@/lib/validators/inspection.validator";
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

// POST /api/bookings/:id/inspections/upload-url — cấp presigned PUT cho 1 ảnh
// kiểm tra xe (check-in/check-out). Chỉ bên của đơn được phép (kiểm tra ở service).
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `inspection-upload:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = inspectionUploadUrlSchema.parse(await req.json());
    return ok(
      await inspectionService.createUploadUrl(claims.sub, params.id, input),
    );
  } catch (error) {
    return toErrorResponse(error);
  }
}
