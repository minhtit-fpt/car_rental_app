import { UserRole } from "@prisma/client";
import { analyticsService } from "@/lib/services/analytics.service";
import { analyticsAskSchema } from "@/lib/validators/admin.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { requireRole } from "@/lib/middleware/role.middleware";

export const runtime = "nodejs";

// POST /api/admin/analytics — NL-analytics: hỏi đáp số liệu qua template whitelist.
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    requireRole(claims, UserRole.ADMIN);
    const input = analyticsAskSchema.parse(await parseJsonBody(req));
    return ok(await analyticsService.ask(input.question));
  } catch (error) {
    return toErrorResponse(error);
  }
}
