import { SignJWT, jwtVerify, type JWTPayload } from "jose";
import type { KycStatus, UserRole } from "@prisma/client";
import { getEnv } from "@/lib/config/env";

// Access token JWT (HS256). Dùng jose vì tương thích Edge runtime của Next.

export interface AccessTokenClaims {
  sub: string; // userId
  roles: UserRole[];
  kycStatus: KycStatus;
}

interface AccessTokenPayload extends JWTPayload {
  roles: UserRole[];
  kycStatus: KycStatus;
  type: "access";
}

function secretKey(): Uint8Array {
  return new TextEncoder().encode(getEnv().JWT_ACCESS_SECRET);
}

export async function signAccessToken(
  claims: AccessTokenClaims,
): Promise<string> {
  return new SignJWT({
    roles: claims.roles,
    kycStatus: claims.kycStatus,
    type: "access",
  })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(claims.sub)
    .setIssuedAt()
    .setExpirationTime(getEnv().JWT_ACCESS_TTL)
    .sign(secretKey());
}

export async function verifyAccessToken(
  token: string,
): Promise<AccessTokenClaims> {
  const { payload } = await jwtVerify<AccessTokenPayload>(token, secretKey());

  if (payload.type !== "access" || typeof payload.sub !== "string") {
    throw new Error("Access token không hợp lệ");
  }

  return {
    sub: payload.sub,
    roles: payload.roles,
    kycStatus: payload.kycStatus,
  };
}
