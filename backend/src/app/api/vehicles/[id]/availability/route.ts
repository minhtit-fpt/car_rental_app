import { vehicleService } from "@/lib/services/vehicle.service";
import { availabilityQuerySchema } from "@/lib/validators/vehicle.validator";
import { ok, toErrorResponse } from "@/lib/http/response";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// GET /api/vehicles/:id/availability — lịch bận suy ra từ các đơn đặt (public).
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const { from, to } = availabilityQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(
      await vehicleService.getAvailability(params.id, {
        from: from ? new Date(from) : undefined,
        to: to ? new Date(to) : undefined,
      }),
    );
  } catch (error) {
    return toErrorResponse(error);
  }
}
