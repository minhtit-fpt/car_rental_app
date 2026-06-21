import { favoriteService } from "@/lib/services/favorite.service";
import { ok, toErrorResponse } from "@/lib/http/response";
import { requireAuth } from "@/lib/middleware/auth.middleware";

export const runtime = "nodejs";

// GET /api/favorites — danh sách xe đã lưu của user hiện tại.
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await favoriteService.list(claims.sub));
  } catch (error) {
    return toErrorResponse(error);
  }
}
