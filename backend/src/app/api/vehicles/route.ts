import { UserRole } from "@prisma/client";
import { vehicleService } from "@/lib/services/vehicle.service";
import {
  createVehicleSchema,
  listVehiclesQuerySchema,
} from "@/lib/validators/vehicle.validator";
import { created, ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const WRITE_RATE_LIMIT = 20;
const WINDOW_SECONDS = 60;

function queryParams(req: Request): Record<string, string> {
  return Object.fromEntries(new URL(req.url).searchParams);
}

// GET /api/vehicles — danh sách + lọc (public). `mine=true` → chỉ xe của người
// gọi (cần đăng nhập).
export async function GET(req: Request): Promise<Response> {
  try {
    const { mine, ...filters } = listVehiclesQuerySchema.parse(queryParams(req));
    if (mine) {
      const claims = await requireAuth(req);
      return ok(await vehicleService.list({ ...filters, ownerId: claims.sub }));
    }
    return ok(await vehicleService.list(filters));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// POST /api/vehicles — chủ xe đăng xe mới (OWNER).
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.OWNER);
    await enforceRateLimit(
      `vehicle-create:${getClientIp(req)}`,
      WRITE_RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = createVehicleSchema.parse(await parseJsonBody(req));
    return created(await vehicleService.create(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
