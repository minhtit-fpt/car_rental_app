import { pricingService } from "@/lib/services/pricing.service";
import { priceQuoteQuerySchema } from "@/lib/validators/vehicle.validator";
import { ok, toErrorResponse } from "@/lib/http/response";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// GET /api/vehicles/:id/price-quote?startTime=&endTime=
// Báo giá động CÓ GIẢI THÍCH (breakdown từng yếu tố surge) cho khoảng thời gian
// thuê. Public/read-only — giá gốc lấy từ DB do chủ xe đặt.
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const { startTime, endTime } = priceQuoteQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(
      await pricingService.quoteForVehicle({
        vehicleId: params.id,
        startTime: new Date(startTime),
        endTime: new Date(endTime),
      }),
    );
  } catch (error) {
    return toErrorResponse(error);
  }
}
