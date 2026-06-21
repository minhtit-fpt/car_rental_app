import { favoriteService } from "@/lib/services/favorite.service";
import { vehicleIdParamSchema } from "@/lib/validators/favorite.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { vehicleId: string };
}

// POST /api/favorites/:vehicleId — thêm xe vào yêu thích.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `favorite-toggle:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const vehicleId = vehicleIdParamSchema.parse(params.vehicleId);
    return ok(await favoriteService.add(claims.sub, vehicleId));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// DELETE /api/favorites/:vehicleId — bỏ xe khỏi yêu thích.
export async function DELETE(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `favorite-toggle:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const vehicleId = vehicleIdParamSchema.parse(params.vehicleId);
    return ok(await favoriteService.remove(claims.sub, vehicleId));
  } catch (error) {
    return toErrorResponse(error);
  }
}
