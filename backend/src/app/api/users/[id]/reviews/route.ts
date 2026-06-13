import { reviewService } from "@/lib/services/review.service";
import { listReviewsQuerySchema } from "@/lib/validators/review.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// GET /api/users/:id/reviews — danh sách đánh giá nhận được + điểm trung bình.
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    await requireAuth(req);
    const query = listReviewsQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await reviewService.listForTarget(params.id, query));
  } catch (error) {
    return toErrorResponse(error);
  }
}
