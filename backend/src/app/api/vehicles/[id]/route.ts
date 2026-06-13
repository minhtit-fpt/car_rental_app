import { vehicleService } from "@/lib/services/vehicle.service";
import { updateVehicleSchema } from "@/lib/validators/vehicle.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const WRITE_RATE_LIMIT = 20;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// GET /api/vehicles/:id — chi tiết xe (public).
export async function GET(
  _req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    return ok(await vehicleService.getById(params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// PATCH /api/vehicles/:id — chủ xe cập nhật (kiểm tra quyền sở hữu trong service).
export async function PATCH(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `vehicle-update:${getClientIp(req)}`,
      WRITE_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = updateVehicleSchema.parse(await parseJsonBody(req));
    return ok(await vehicleService.update(claims.sub, params.id, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// DELETE /api/vehicles/:id — chủ xe gỡ xe.
export async function DELETE(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `vehicle-delete:${getClientIp(req)}`,
      WRITE_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    await vehicleService.remove(claims.sub, params.id);
    return ok({ id: params.id, deleted: true });
  } catch (error) {
    return toErrorResponse(error);
  }
}
