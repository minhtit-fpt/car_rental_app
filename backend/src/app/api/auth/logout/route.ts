import { authService } from "@/lib/services/auth.service";
import { refreshSchema } from "@/lib/validators/auth.validator";
import { ok, toErrorResponse } from "@/lib/http/response";
import { parseJsonBody } from "@/lib/http/request";

export const runtime = "nodejs";

export async function POST(req: Request): Promise<Response> {
  try {
    const { refreshToken } = refreshSchema.parse(await parseJsonBody(req));
    await authService.logout(refreshToken);
    return ok({ loggedOut: true });
  } catch (error) {
    return toErrorResponse(error);
  }
}
