import { trackingService } from "@/lib/services/tracking.service";
import { ingestLocationSchema } from "@/lib/validators/tracking.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";
import { AppError } from "@/lib/errors/app-error";
import { getEnv } from "@/lib/config/env";

export const runtime = "nodejs";

// Điểm GPS dày nên nới hơn write thường, nhưng vẫn chặn spam theo từng xe.
const INGEST_RATE_LIMIT = 60;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { vehicleId: string };
}

// POST /api/tracking/:vehicleId — nhận toạ độ từ simulator / thiết bị GPS.
// Xác thực bằng header `x-device-key` khớp env TRACKING_DEVICE_KEY (fail-closed:
// env chưa đặt → luôn từ chối).
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const deviceKey = getEnv().TRACKING_DEVICE_KEY;
    const provided = req.headers.get("x-device-key");
    if (!deviceKey || provided !== deviceKey) {
      throw new AppError(401, "UNAUTHORIZED", "Thiết bị không hợp lệ");
    }
    await enforceRateLimit(
      `tracking-ingest:${params.vehicleId}`,
      INGEST_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = ingestLocationSchema.parse(await parseJsonBody(req));
    await trackingService.ingest(params.vehicleId, input);
    return ok({ accepted: true });
  } catch (error) {
    return toErrorResponse(error);
  }
}
