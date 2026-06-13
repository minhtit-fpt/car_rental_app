import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/auth.service", () => ({
  authService: {
    register: vi.fn(),
    login: vi.fn(),
    refresh: vi.fn(),
    logout: vi.fn(),
    getCurrentUser: vi.fn(),
  },
}));

import { POST as registerPOST } from "@/app/api/auth/register/route";
import { POST as loginPOST } from "@/app/api/auth/login/route";
import { POST as refreshPOST } from "@/app/api/auth/refresh/route";
import { POST as logoutPOST } from "@/app/api/auth/logout/route";
import { GET as meGET } from "@/app/api/auth/me/route";
import { authService } from "@/lib/services/auth.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";

function jsonReq(body: unknown, raw?: string): Request {
  return new Request("http://localhost/api/auth", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: raw ?? JSON.stringify(body),
  });
}

const PUBLIC_USER = {
  id: "user-1",
  phone: "+84901234567",
  email: null,
  roles: [UserRole.RENTER],
  kycStatus: KycStatus.UNVERIFIED,
};
const TOKENS = { accessToken: "a.jwt", refreshToken: "raw-refresh" };

beforeEach(() => vi.clearAllMocks());

describe("POST /api/auth/register", () => {
  it("returns 201 with the created user and tokens", async () => {
    vi.mocked(authService.register).mockResolvedValue({
      user: PUBLIC_USER,
      tokens: TOKENS,
    });
    const res = await registerPOST(
      jsonReq({ phone: "0901234567", password: "password1" }),
    );
    expect(res.status).toBe(201);
    const json = await res.json();
    expect(json).toMatchObject({ success: true, data: { tokens: TOKENS } });
  });

  it("returns 409 when the phone is taken", async () => {
    vi.mocked(authService.register).mockRejectedValue(
      new AppError(409, "PHONE_TAKEN", "Số điện thoại đã được đăng ký"),
    );
    const res = await registerPOST(
      jsonReq({ phone: "0901234567", password: "password1" }),
    );
    expect(res.status).toBe(409);
    expect((await res.json()).code).toBe("PHONE_TAKEN");
  });

  it("returns 400 VALIDATION_ERROR on an invalid phone", async () => {
    const res = await registerPOST(
      jsonReq({ phone: "123", password: "password1" }),
    );
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("VALIDATION_ERROR");
  });

  it("returns 400 INVALID_JSON on a malformed body", async () => {
    const res = await registerPOST(jsonReq(null, "{not json"));
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("INVALID_JSON");
  });
});

describe("POST /api/auth/login", () => {
  it("returns 200 on success", async () => {
    vi.mocked(authService.login).mockResolvedValue({
      user: PUBLIC_USER,
      tokens: TOKENS,
    });
    const res = await loginPOST(
      jsonReq({ phone: "0901234567", password: "password1" }),
    );
    expect(res.status).toBe(200);
    expect((await res.json()).success).toBe(true);
  });

  it("returns 401 on invalid credentials", async () => {
    vi.mocked(authService.login).mockRejectedValue(
      new AppError(401, "INVALID_CREDENTIALS", "Sai thông tin"),
    );
    const res = await loginPOST(
      jsonReq({ phone: "0901234567", password: "wrong-pass" }),
    );
    expect(res.status).toBe(401);
    expect((await res.json()).code).toBe("INVALID_CREDENTIALS");
  });
});

describe("POST /api/auth/refresh", () => {
  it("returns 200 with rotated tokens", async () => {
    vi.mocked(authService.refresh).mockResolvedValue(TOKENS);
    const res = await refreshPOST(jsonReq({ refreshToken: "old-token" }));
    expect(res.status).toBe(200);
    expect((await res.json()).data.tokens).toEqual(TOKENS);
  });

  it("returns 401 on an invalid refresh token", async () => {
    vi.mocked(authService.refresh).mockRejectedValue(
      new AppError(401, "INVALID_REFRESH_TOKEN", "Không hợp lệ"),
    );
    const res = await refreshPOST(jsonReq({ refreshToken: "bad" }));
    expect(res.status).toBe(401);
  });
});

describe("POST /api/auth/logout", () => {
  it("returns 200 and is idempotent", async () => {
    vi.mocked(authService.logout).mockResolvedValue(undefined);
    const res = await logoutPOST(jsonReq({ refreshToken: "tok" }));
    expect(res.status).toBe(200);
    expect((await res.json()).data).toEqual({ loggedOut: true });
  });
});

describe("GET /api/auth/me", () => {
  it("returns 200 with the current user when authenticated", async () => {
    vi.mocked(requireAuth).mockResolvedValue({
      sub: "user-1",
      roles: [UserRole.RENTER],
      kycStatus: KycStatus.UNVERIFIED,
    });
    vi.mocked(authService.getCurrentUser).mockResolvedValue(PUBLIC_USER);
    const res = await meGET(new Request("http://localhost/api/auth/me"));
    expect(res.status).toBe(200);
    expect((await res.json()).data.id).toBe("user-1");
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );
    const res = await meGET(new Request("http://localhost/api/auth/me"));
    expect(res.status).toBe(401);
    expect((await res.json()).code).toBe("UNAUTHORIZED");
  });
});
