import { AppError } from "@/lib/errors/app-error";

export async function parseJsonBody(req: Request): Promise<unknown> {
  try {
    return await req.json();
  } catch {
    throw new AppError(400, "INVALID_JSON", "Body không phải JSON hợp lệ");
  }
}

// Lấy IP client để làm khóa rate limit (sau reverse proxy).
export function getClientIp(req: Request): string {
  const forwarded = req.headers.get("x-forwarded-for");
  if (forwarded) {
    return forwarded.split(",")[0]?.trim() ?? "unknown";
  }
  return req.headers.get("x-real-ip") ?? "unknown";
}
