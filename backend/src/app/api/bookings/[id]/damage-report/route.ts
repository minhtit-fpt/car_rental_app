import { inspectionService } from "@/lib/services/inspection.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

// Phân tích VLM nặng → giới hạn chặt hơn các route đọc.
const ANALYZE_RATE_LIMIT = 6;
const READ_RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// POST /api/bookings/:id/damage-report — chạy VLM so ảnh check-in/out → lưu báo cáo.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `damage-analyze:${getClientIp(req)}`,
      ANALYZE_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await inspectionService.analyzeDamage(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// GET /api/bookings/:id/damage-report — lấy báo cáo hư hỏng đã lưu + ảnh.
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `damage-read:${getClientIp(req)}`,
      READ_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await inspectionService.getReport(claims.sub, params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
