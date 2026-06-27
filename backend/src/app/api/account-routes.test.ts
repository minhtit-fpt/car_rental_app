import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/auth.service", () => ({
  authService: { changePassword: vi.fn() },
}));
vi.mock("@/lib/services/user.service", () => ({
  userService: { updateProfile: vi.fn(), deleteAccount: vi.fn() },
}));

import { PATCH as changePasswordPATCH } from "@/app/api/auth/change-password/route";
import { DELETE as deleteAccountDELETE } from "@/app/api/users/me/route";
import { authService } from "@/lib/services/auth.service";
import { userService } from "@/lib/services/user.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";

const CLAIMS = { sub: "user-1", roles: [], kycStatus: "UNVERIFIED" };

function req(method: string, body?: unknown): Request {
  return new Request("http://localhost/api", {
    method,
    headers: { "content-type": "application/json" },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}

beforeEach(() => {
  vi.clearAllMocks();
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  vi.mocked(requireAuth).mockResolvedValue(CLAIMS as any);
});

describe("PATCH /api/auth/change-password", () => {
  it("returns 200 when the password is changed", async () => {
    vi.mocked(authService.changePassword).mockResolvedValue();
    const res = await changePasswordPATCH(
      req("PATCH", {
        currentPassword: "oldpass1",
        newPassword: "newpass12",
      }),
    );
    expect(res.status).toBe(200);
    expect((await res.json()).success).toBe(true);
    expect(authService.changePassword).toHaveBeenCalledWith("user-1", {
      currentPassword: "oldpass1",
      newPassword: "newpass12",
    });
  });

  it("returns 400 INVALID_CURRENT_PASSWORD when current password is wrong", async () => {
    vi.mocked(authService.changePassword).mockRejectedValue(
      new AppError(
        400,
        "INVALID_CURRENT_PASSWORD",
        "Mật khẩu hiện tại không đúng",
      ),
    );
    const res = await changePasswordPATCH(
      req("PATCH", {
        currentPassword: "wrongpass",
        newPassword: "newpass12",
      }),
    );
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("INVALID_CURRENT_PASSWORD");
  });

  it("returns 400 VALIDATION_ERROR when the new password is too short", async () => {
    const res = await changePasswordPATCH(
      req("PATCH", { currentPassword: "oldpass1", newPassword: "short" }),
    );
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("VALIDATION_ERROR");
    expect(authService.changePassword).not.toHaveBeenCalled();
  });

  it("returns 400 VALIDATION_ERROR when the new password equals the current one", async () => {
    const res = await changePasswordPATCH(
      req("PATCH", { currentPassword: "samepass1", newPassword: "samepass1" }),
    );
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("VALIDATION_ERROR");
  });
});

describe("DELETE /api/users/me", () => {
  it("returns 200 when the account is deleted", async () => {
    vi.mocked(userService.deleteAccount).mockResolvedValue();
    const res = await deleteAccountDELETE(req("DELETE"));
    expect(res.status).toBe(200);
    expect((await res.json())).toMatchObject({
      success: true,
      data: { deleted: true },
    });
    expect(userService.deleteAccount).toHaveBeenCalledWith("user-1");
  });

  it("returns 404 when the user no longer exists", async () => {
    vi.mocked(userService.deleteAccount).mockRejectedValue(
      new AppError(404, "USER_NOT_FOUND", "Không tìm thấy người dùng"),
    );
    const res = await deleteAccountDELETE(req("DELETE"));
    expect(res.status).toBe(404);
    expect((await res.json()).code).toBe("USER_NOT_FOUND");
  });
});
