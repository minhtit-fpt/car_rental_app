import { chatService } from "@/lib/services/chat.service";
import {
  listMessagesQuerySchema,
  sendMessageSchema,
} from "@/lib/validators/chat.validator";
import { created, ok, toErrorResponse } from "@/lib/http/response";
import { getClientIp, parseJsonBody } from "@/lib/http/request";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";

export const runtime = "nodejs";

const RATE_LIMIT = 60;
const WINDOW_SECONDS = 60;

interface RouteContext {
  params: { id: string };
}

// GET /api/conversations/:id/messages — tin nhắn trong hội thoại (mới trước).
export async function GET(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    const query = listMessagesQuerySchema.parse(
      Object.fromEntries(new URL(req.url).searchParams),
    );
    return ok(await chatService.listMessages(claims.sub, params.id, query));
  } catch (error) {
    return toErrorResponse(error);
  }
}

// POST /api/conversations/:id/messages — gửi tin nhắn.
export async function POST(
  req: Request,
  { params }: RouteContext,
): Promise<Response> {
  try {
    const claims = await requireAuth(req);
    await enforceRateLimit(
      `message-send:${getClientIp(req)}`,
      RATE_LIMIT,
      WINDOW_SECONDS,
    );
    const input = sendMessageSchema.parse(await parseJsonBody(req));
    return created(
      await chatService.sendMessage(claims.sub, params.id, input),
    );
  } catch (error) {
    return toErrorResponse(error);
  }
}
