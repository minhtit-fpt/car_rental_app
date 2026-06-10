import type { UserRole } from "@prisma/client";
import type { AccessTokenClaims } from "@/lib/auth/jwt";
import { AppError } from "@/lib/errors/app-error";

// Bắt buộc claims phải có một vai trò cụ thể. Ném AppError(403) nếu thiếu.
export function requireRole(claims: AccessTokenClaims, role: UserRole): void {
  if (!claims.roles.includes(role)) {
    throw new AppError(
      403,
      "FORBIDDEN",
      "Bạn không có quyền thực hiện thao tác này",
    );
  }
}
