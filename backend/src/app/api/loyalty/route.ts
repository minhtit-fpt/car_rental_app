import { loyaltyService } from "@/lib/services/loyalty.service";
import { listLoyaltyQuerySchema } from "@/lib/validators/loyalty.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

// GET /api/loyalty — tổng điểm + hạng + lịch sử tích/tiêu điểm.
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    const query = listLoyaltyQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await loyaltyService.getSummary(claims.sub, query));
  } catch (error) {
    return toErrorResponse(error);
  }
}
