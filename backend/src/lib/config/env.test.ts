import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { getEnv } from "@/lib/config/env";

const VALID_ENV = {
  DATABASE_URL: "postgresql://u:p@localhost:5432/db",
  REDIS_URL: "redis://localhost:6379",
  JWT_ACCESS_SECRET: "a".repeat(40),
};

describe("getEnv", () => {
  const original = process.env;

  beforeEach(() => {
    process.env = { ...original };
  });

  afterEach(() => {
    process.env = original;
  });

  it("parses valid env and applies defaults", () => {
    Object.assign(process.env, VALID_ENV, { NODE_ENV: "test" });
    delete process.env.JWT_ACCESS_TTL;
    delete process.env.JWT_REFRESH_TTL_DAYS;

    const env = getEnv();

    expect(env.JWT_ACCESS_TTL).toBe("15m");
    expect(env.JWT_REFRESH_TTL_DAYS).toBe(30);
  });

  it("throws when JWT_ACCESS_SECRET is too short", () => {
    Object.assign(process.env, VALID_ENV, { JWT_ACCESS_SECRET: "short" });

    expect(() => getEnv()).toThrow(/JWT_ACCESS_SECRET/);
  });

  it("throws when DATABASE_URL is missing", () => {
    Object.assign(process.env, VALID_ENV);
    delete process.env.DATABASE_URL;

    expect(() => getEnv()).toThrow(/DATABASE_URL/);
  });
});
