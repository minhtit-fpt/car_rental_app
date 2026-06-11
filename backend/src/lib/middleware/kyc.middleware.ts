import { KycStatus } from "@prisma/client";
import type { AccessTokenClaims } from "@/lib/auth/jwt";
import { AppError } from "@/lib/errors/app-error";

// Bắt buộc người dùng đã xác minh KYC (đọc từ claims của access token).
// Lưu ý: token TTL ngắn (15m) nên trạng thái có thể trễ tối đa 1 chu kỳ refresh.
export function requireKycVerified(claims: AccessTokenClaims): void {
  if (claims.kycStatus !== KycStatus.VERIFIED) {
    throw new AppError(
      403,
      "KYC_REQUIRED",
      "Bạn cần xác minh danh tính (KYC) trước khi đặt xe",
    );
  }
}
