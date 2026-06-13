import { describe, expect, it } from "vitest";
import {
  loginSchema,
  refreshSchema,
  registerSchema,
} from "@/lib/validators/auth.validator";

describe("registerSchema", () => {
  it("accepts and normalizes a VN phone", () => {
    const result = registerSchema.parse({
      phone: "0901234567",
      password: "password1",
    });
    expect(result.phone).toBe("+84901234567");
  });

  it("accepts an optional valid email", () => {
    const result = registerSchema.parse({
      phone: "0901234567",
      password: "password1",
      email: "user@example.com",
    });
    expect(result.email).toBe("user@example.com");
  });

  it("rejects a password shorter than 8 chars", () => {
    expect(() =>
      registerSchema.parse({ phone: "0901234567", password: "short" }),
    ).toThrow();
  });

  it("rejects an invalid phone", () => {
    expect(() =>
      registerSchema.parse({ phone: "123", password: "password1" }),
    ).toThrow();
  });

  it("rejects an invalid email", () => {
    expect(() =>
      registerSchema.parse({
        phone: "0901234567",
        password: "password1",
        email: "not-an-email",
      }),
    ).toThrow();
  });
});

describe("loginSchema", () => {
  it("normalizes phone and requires a password", () => {
    const result = loginSchema.parse({ phone: "0901234567", password: "x" });
    expect(result.phone).toBe("+84901234567");
  });
});

describe("refreshSchema", () => {
  it("rejects an empty refreshToken", () => {
    expect(() => refreshSchema.parse({ refreshToken: "" })).toThrow();
  });

  it("accepts a non-empty refreshToken", () => {
    expect(refreshSchema.parse({ refreshToken: "abc" }).refreshToken).toBe(
      "abc",
    );
  });
});
