import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/db/redis", () => ({
  redis: { incr: vi.fn(), expire: vi.fn() },
}));

import { enforceRateLimit } from "@/lib/middleware/rate-limit.middleware";
import { redis } from "@/db/redis";

beforeEach(() => vi.clearAllMocks());

describe("enforceRateLimit", () => {
  it("allows the first request and sets the window expiry", async () => {
    vi.mocked(redis.incr).mockResolvedValue(1);
    await expect(enforceRateLimit("k", 5, 60)).resolves.toBeUndefined();
    expect(redis.expire).toHaveBeenCalledWith("ratelimit:k", 60);
  });

  it("allows requests at or under the limit without resetting expiry", async () => {
    vi.mocked(redis.incr).mockResolvedValue(5);
    await expect(enforceRateLimit("k", 5, 60)).resolves.toBeUndefined();
    expect(redis.expire).not.toHaveBeenCalled();
  });

  it("throws 429 when the limit is exceeded", async () => {
    vi.mocked(redis.incr).mockResolvedValue(6);
    await expect(enforceRateLimit("k", 5, 60)).rejects.toMatchObject({
      status: 429,
      code: "RATE_LIMITED",
    });
  });
});
