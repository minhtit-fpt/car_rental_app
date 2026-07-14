import { timingSafeEqual } from "node:crypto";
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

// So sánh constant-time để tránh timing attack khi đối chiếu device key.
function keysMatch(provided: string, expected: string): boolean {
  const a = Buffer.from(provided);
  const b = Buffer.from(expected);
  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

interface RouteContext {
  params: { vehicleId: string };
}

// POST /api/tracking/:vehicleId — nhận toạ độ từ simulator / thiết bị GPS.
// Xác thực bằng header `x-device-key` khớp env TRACKING_DEVICE_KEY (fail-closed:
// env chưa đặt → luôn từ chối).
// TODO(security): key toàn cục — 1 key leak giả mạo được toạ độ MỌI xe. Khi có
// hardware thật, đổi sang token per-vehicle (thêm cột Vehicle.deviceToken hoặc
// HMAC keyed theo vehicleId) để giới hạn thiết bị chỉ ghi cho đúng xe của nó.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    // Rate-limit TRƯỚC khi kiểm tra key: request key sai/thiếu vẫn bị chặn spam
    // (nếu chỉ chặn sau auth thì flood 401 không bị throttle → DoS).
    await enforceRateLimit(
      `tracking-ingest:${params.vehicleId}`,
      INGEST_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const deviceKey = getEnv().TRACKING_DEVICE_KEY;
    const provided = req.headers.get("x-device-key");
    if (!deviceKey || !provided || !keysMatch(provided, deviceKey)) {
      throw new AppError(401, "UNAUTHORIZED", "Thiết bị không hợp lệ");
    }
    const input = ingestLocationSchema.parse(await parseJsonBody(req));
    await trackingService.ingest(params.vehicleId, input);
    return ok({ accepted: true });
  } catch (error) {
    return toErrorResponse(error);
  }
}
