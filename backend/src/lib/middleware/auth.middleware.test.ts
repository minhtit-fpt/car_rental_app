import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/auth/jwt", () => ({ verifyAccessToken: vi.fn() }));

import { requireAuth } from "@/lib/middleware/auth.middleware";
import { verifyAccessToken } from "@/lib/auth/jwt";

const CLAIMS = {
  sub: "user-1",
  roles: [UserRole.RENTER],
  kycStatus: KycStatus.UNVERIFIED,
};

function reqWith(authorization?: string): Request {
  const headers = new Headers();
  if (authorization) headers.set("authorization", authorization);
  return new Request("http://localhost/api/auth/me", { headers });
}

beforeEach(() => vi.clearAllMocks());

describe("requireAuth", () => {
  it("returns claims for a valid Bearer token", async () => {
    vi.mocked(verifyAccessToken).mockResolvedValue(CLAIMS);
    expect(await requireAuth(reqWith("Bearer good.token"))).toEqual(CLAIMS);
    expect(verifyAccessToken).toHaveBeenCalledWith("good.token");
  });

  it("throws 401 when the header is missing", async () => {
    await expect(requireAuth(reqWith())).rejects.toMatchObject({
      status: 401,
      code: "UNAUTHORIZED",
    });
  });

  it("throws 401 when the scheme is not Bearer", async () => {
    await expect(requireAuth(reqWith("Basic abc"))).rejects.toMatchObject({
      status: 401,
    });
  });

  it("throws 401 when the token is invalid", async () => {
    vi.mocked(verifyAccessToken).mockRejectedValue(new Error("expired"));
    await expect(requireAuth(reqWith("Bearer bad"))).rejects.toMatchObject({
      status: 401,
      code: "UNAUTHORIZED",
    });
  });
});
