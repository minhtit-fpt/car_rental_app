import { vehicleService } from "@/lib/services/vehicle.service";
import { nearbyQuerySchema } from "@/lib/validators/vehicle.validator";
import { ok, toErrorResponse } from "@/lib/http/response";

export const runtime = "nodejs";

// GET /api/vehicles/nearby?lat&lng&radius&limit — xe gần vị trí (PostGIS).
export async function GET(req: Request): Promise<Response> {
  try {
    const params = nearbyQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await vehicleService.nearby(params));
  } catch (error) {
    return toErrorResponse(error);
  }
}
