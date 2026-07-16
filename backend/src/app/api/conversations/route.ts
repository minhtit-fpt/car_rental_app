import { chatService } from "@/lib/services/chat.service";
import { createConversationSchema } from "@/lib/validators/chat.validator";
import { created, ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 20;
const WINDOW_SECONDS = 60;

// GET /api/conversations — danh sách hội thoại của người dùng.
export async function GET(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    return ok(await chatService.listConversations(claims.sub));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// POST /api/conversations — tạo/lấy hội thoại theo booking hoặc người dùng khác.
export async function POST(req: Request): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    // Giới hạn theo user (không theo IP — tránh 429 oan khi chung NAT).
    await enforceRateLimit(
      `conversation-create:${claims.sub}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = createConversationSchema.parse(await parseJsonBody(req));
    return created(await chatService.createOrGetConversation(claims.sub, input));
  } catch (error) {
    return toErrorResponse(error);
  }
}
