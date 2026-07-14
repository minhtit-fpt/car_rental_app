import { beforeEach, describe, expect, it, vi } from "vitest";
import { UserRole, type Booking, type Vehicle } from "@prisma/client";

vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: { findById: vi.fn() },
}));
vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: { findInProgressByVehicle: vi.fn() },
}));
vi.mock("@/lib/repositories/tracking.repository", () => ({
  trackingRepository: {
    insert: vi.fn(),
    findRecent: vi.fn(),
    findActiveLatest: vi.fn(),
  },
}));

import { trackingService } from "@/lib/services/tracking.service";
import { AppError } from "@/lib/errors/app-error";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { trackingRepository } from "@/lib/repositories/tracking.repository";

const VEHICLE = { id: "veh-1", ownerId: "owner-1" } as Vehicle;
const BOOKING = { id: "bk-1", renterId: "renter-1" } as Booking;

function claims(sub: string, roles: UserRole[] = [UserRole.RENTER]) {
  return { sub, roles, kycStatus: "VERIFIED" } as never;
}

function point(overrides = {}) {
  return {
    id: "loc-1",
    vehicleId: "veh-1",
    bookingId: "bk-1",
    lat: 21.02,
    lng: 105.83,
    speedKmh: 40,
    recordedAt: new Date("2026-07-13T10:00:00Z"),
    ...overrides,
  };
}

beforeEach(() => vi.clearAllMocks());

describe("trackingService.ingest", () => {
  it("attaches in-progress bookingId when present", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(
      BOOKING,
    );
    await trackingService.ingest("veh-1", { lat: 21, lng: 105 });
    expect(trackingRepository.insert).toHaveBeenCalledWith(
      expect.objectContaining({ vehicleId: "veh-1", bookingId: "bk-1" }),
    );
  });

  it("inserts with null bookingId when no active trip", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(null);
    await trackingService.ingest("veh-1", { lat: 21, lng: 105 });
    expect(trackingRepository.insert).toHaveBeenCalledWith(
      expect.objectContaining({ bookingId: null }),
    );
  });

  it("throws 404 for unknown vehicle", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(null);
    await expect(
      trackingService.ingest("nope", { lat: 21, lng: 105 }),
    ).rejects.toBeInstanceOf(AppError);
  });
});

describe("trackingService.getSnapshot", () => {
  it("returns latest + reversed trail for the renter", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(
      BOOKING,
    );
    // repo trả mới→cũ
    vi.mocked(trackingRepository.findRecent).mockResolvedValue([
      point({ recordedAt: new Date("2026-07-13T10:02:00Z") }),
      point({ recordedAt: new Date("2026-07-13T10:00:00Z") }),
    ] as never);
    const snap = await trackingService.getSnapshot(
      claims("renter-1"),
      "veh-1",
      20,
    );
    expect(snap.latest.recordedAt.toISOString()).toBe(
      "2026-07-13T10:02:00.000Z",
    );
    // trail đảo lại cũ→mới
    expect(snap.trail[0].recordedAt.toISOString()).toBe(
      "2026-07-13T10:00:00.000Z",
    );
  });

  it("allows the owner", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(
      BOOKING,
    );
    vi.mocked(trackingRepository.findRecent).mockResolvedValue([
      point(),
    ] as never);
    await expect(
      trackingService.getSnapshot(claims("owner-1"), "veh-1", 0),
    ).resolves.toMatchObject({ vehicleId: "veh-1" });
  });

  it("allows admin", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(
      BOOKING,
    );
    vi.mocked(trackingRepository.findRecent).mockResolvedValue([
      point(),
    ] as never);
    await expect(
      trackingService.getSnapshot(
        claims("someone", [UserRole.ADMIN]),
        "veh-1",
        0,
      ),
    ).resolves.toMatchObject({ vehicleId: "veh-1" });
  });

  it("403 for an unrelated user", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(
      BOOKING,
    );
    await expect(
      trackingService.getSnapshot(claims("stranger"), "veh-1", 0),
    ).rejects.toMatchObject({ status: 403, code: "FORBIDDEN" });
  });

  it("403 when vehicle not in an active trip (privacy)", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(VEHICLE);
    vi.mocked(bookingRepository.findInProgressByVehicle).mockResolvedValue(null);
    await expect(
      trackingService.getSnapshot(claims("owner-1"), "veh-1", 0),
    ).rejects.toMatchObject({ status: 403, code: "TRACKING_UNAVAILABLE" });
  });
});

describe("trackingService.listActive", () => {
  it("403 for non-admin", async () => {
    await expect(
      trackingService.listActive(claims("renter-1")),
    ).rejects.toMatchObject({ status: 403 });
  });

  it("returns rows for admin", async () => {
    vi.mocked(trackingRepository.findActiveLatest).mockResolvedValue([]);
    await expect(
      trackingService.listActive(claims("admin", [UserRole.ADMIN])),
    ).resolves.toEqual([]);
  });
});
