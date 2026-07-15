import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/repositories/favorite.repository", () => ({
  favoriteRepository: {
    findByUser: vi.fn(),
    add: vi.fn(),
    remove: vi.fn(),
  },
}));
vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: {
    findById: vi.fn(),
  },
}));

import { favoriteService } from "@/lib/services/favorite.service";
import { favoriteRepository } from "@/lib/repositories/favorite.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { AppError } from "@/lib/errors/app-error";

const USER = "user-1";
const VEHICLE = "veh-1";

function makeVehicle(overrides: Record<string, unknown> = {}) {
  return {
    id: VEHICLE,
    ownerId: "owner-1",
    type: "CAR",
    title: "Vinfast VF8",
    pricePerDay: 120,
    isElectric: true,
    isAvailable: true,
    deliveryAvailable: false,
    seats: 5,
    doors: 4,
    transmission: "AUTOMATIC",
    city: "Hà Nội",
    createdAt: new Date("2026-06-01T00:00:00Z"),
    updatedAt: new Date("2026-06-01T00:00:00Z"),
    ...overrides,
  };
}

function makeFavoriteRow(overrides: Record<string, unknown> = {}) {
  return {
    id: "fav-1",
    userId: USER,
    vehicleId: VEHICLE,
    createdAt: new Date("2026-06-02T00:00:00Z"),
    vehicle: { ...makeVehicle(), owner: { name: "Anh Tài" } },
    ...overrides,
  };
}

beforeEach(() => vi.clearAllMocks());

describe("favoriteService.list", () => {
  it("maps saved favorites to public vehicles with owner name", async () => {
    vi.mocked(favoriteRepository.findByUser).mockResolvedValue([
      makeFavoriteRow() as never,
    ]);

    const result = await favoriteService.list(USER);

    expect(favoriteRepository.findByUser).toHaveBeenCalledWith(USER);
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe(VEHICLE);
    expect(result[0]?.ownerName).toBe("Anh Tài");
    expect(result[0]?.pricePerDay).toBe(120);
  });
});

describe("favoriteService.add", () => {
  it("adds a favorite when the vehicle exists", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(
      makeVehicle() as never,
    );

    const result = await favoriteService.add(USER, VEHICLE);

    expect(favoriteRepository.add).toHaveBeenCalledWith(USER, VEHICLE);
    expect(result).toEqual({ vehicleId: VEHICLE, favorited: true });
  });

  it("throws 404 when the vehicle does not exist", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(null);

    await expect(favoriteService.add(USER, "missing")).rejects.toThrow(
      AppError,
    );
    expect(favoriteRepository.add).not.toHaveBeenCalled();
  });
});

describe("favoriteService.remove", () => {
  it("removes a favorite and reports favorited false", async () => {
    const result = await favoriteService.remove(USER, VEHICLE);

    expect(favoriteRepository.remove).toHaveBeenCalledWith(USER, VEHICLE);
    expect(result).toEqual({ vehicleId: VEHICLE, favorited: false });
  });
});
