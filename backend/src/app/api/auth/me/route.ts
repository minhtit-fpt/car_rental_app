import { authService } from "@/lib/services/auth.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await authService.getCurrentUser(claims.sub));
  } catch (error) {
    return toErrorResponse(error);
  }
}
