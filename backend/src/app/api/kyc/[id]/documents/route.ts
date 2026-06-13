import { UserRole } from "@prisma/client";
import { kycService } from "@/lib/services/kyc.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 30;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// ADMIN-only: trả presigned GET ngắn hạn cho ảnh KYC để duyệt.
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    await enforceRateLimit(
      `kyc-docs:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    return ok(await kycService.getReviewDocuments(params.id));
  } catch (error) {
    return toErrorResponse(error);
  }
}
