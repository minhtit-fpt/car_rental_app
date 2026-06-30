import { UserRole } from "@prisma/client";
import { disputeAnalysisService } from "@/lib/services/dispute-analysis.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

interface RouteContext {
  params: { id: string };
}

// POST /api/admin/disputes/:id/analyze — trợ lý AI tổng hợp ngữ cảnh tranh chấp.
// Lazy-generate (không cache). Advisory: trả fact cứng + neo hoàn tiền + AI tuỳ
// chọn; LM Studio offline vẫn trả fact, ai = null.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    return ok(await disputeAnalysisService.analyze(params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
