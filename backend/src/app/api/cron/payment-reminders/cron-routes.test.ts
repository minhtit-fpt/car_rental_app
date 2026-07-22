import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/services/booking.service", () => ({
  bookingService: {
    expireOverduePayments: vi.fn(),
    expireOverdueOwnerApprovals: vi.fn(),
    completeOverdueBookings: vi.fn(),
  },
}));

vi.mock("@/lib/services/tracking.service", () => ({
  trackingService: { pruneOldLocations: vi.fn() },
}));

import { POST } from "@/app/api/cron/payment-reminders/route";
import { bookingService } from "@/lib/services/booking.service";
import { trackingService } from "@/lib/services/tracking.service";

const SECRET = "test-cron-secret";

function req(secret?: string): Request {
  return new Request("http://localhost/api/cron/payment-reminders", {
    method: "POST",
    headers: secret === undefined ? {} : { "x-cron-secret": secret },
  });
}

const ORIGINAL_SECRET = process.env.CRON_SECRET;

beforeEach(() => vi.clearAllMocks());

afterEach(() => {
  if (ORIGINAL_SECRET === undefined) delete process.env.CRON_SECRET;
  else process.env.CRON_SECRET = ORIGINAL_SECRET;
});

describe("POST /api/cron/payment-reminders", () => {
  it("returns 503 when CRON_SECRET is not configured", async () => {
    delete process.env.CRON_SECRET;

    const res = await POST(req(SECRET));

    expect(res.status).toBe(503);
    expect((await res.json()).code).toBe("CRON_NOT_CONFIGURED");
    expect(bookingService.expireOverduePayments).not.toHaveBeenCalled();
  });

  it("returns 401 when the secret header is missing", async () => {
    process.env.CRON_SECRET = SECRET;

    const res = await POST(req());

    expect(res.status).toBe(401);
    expect((await res.json()).code).toBe("UNAUTHORIZED");
    expect(bookingService.expireOverduePayments).not.toHaveBeenCalled();
  });

  it("returns 401 when the secret header is wrong", async () => {
    process.env.CRON_SECRET = SECRET;

    const res = await POST(req("wrong-secret"));

    expect(res.status).toBe(401);
    expect((await res.json()).code).toBe("UNAUTHORIZED");
    expect(bookingService.expireOverduePayments).not.toHaveBeenCalled();
  });

  it("runs both expiry sweeps and returns their counts when the secret matches", async () => {
    process.env.CRON_SECRET = SECRET;
    vi.mocked(bookingService.expireOverduePayments).mockResolvedValue({
      expired: 4,
    });
    vi.mocked(bookingService.expireOverdueOwnerApprovals).mockResolvedValue({
      expired: 2,
    });
    vi.mocked(bookingService.completeOverdueBookings).mockResolvedValue({
      completed: 3,
    });
    vi.mocked(trackingService.pruneOldLocations).mockResolvedValue({
      pruned: 9,
    });

    const res = await POST(req(SECRET));

    expect(res.status).toBe(200);
    expect((await res.json()).data).toEqual({
      expiredPayments: 4,
      expiredOwnerApprovals: 2,
      completedBookings: 3,
      prunedLocations: 9,
    });
    expect(bookingService.expireOverduePayments).toHaveBeenCalledOnce();
    expect(bookingService.expireOverdueOwnerApprovals).toHaveBeenCalledOnce();
    expect(bookingService.completeOverdueBookings).toHaveBeenCalledOnce();
    expect(trackingService.pruneOldLocations).toHaveBeenCalledOnce();
  });
});
