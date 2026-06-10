import { describe, expect, it } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";
import { requireRole } from "@/lib/middleware/role.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function claims(roles: UserRole[]): AccessTokenClaims {
  return { sub: "user-1", roles, kycStatus: KycStatus.VERIFIED };
}

describe("requireRole", () => {
  it("passes when the claims include the required role", () => {
    expect(() =>
      requireRole(claims([UserRole.ADMIN]), UserRole.ADMIN),
    ).not.toThrow();
  });

  it("throws 403 FORBIDDEN when the role is missing", () => {
    try {
      requireRole(claims([UserRole.RENTER]), UserRole.ADMIN);
      expect.unreachable("should have thrown");
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      expect((error as AppError).status).toBe(403);
      expect((error as AppError).code).toBe("FORBIDDEN");
    }
  });
});
