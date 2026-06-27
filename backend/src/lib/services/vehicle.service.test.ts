import { beforeEach, describe, expect, it, vi } from "vitest";
import { VehicleType, type Vehicle } from "@prisma/client";
import { Prisma } from "@prisma/client";

vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: {
    findMany: vi.fn(),
    findById: vi.fn(),
    findByIdWithOwner: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    findNearby: vi.fn(),
  },
}));

import { vehicleService } from "@/lib/services/vehicle.service";
import { AppError } from "@/lib/errors/app-error";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";

function makeVehicle(overrides: Partial<Vehicle> = {}): Vehicle {
  return {
    id: "veh-1",
    ownerId: "owner-1",
    type: VehicleType.CAR,
    title: "Vinfast VF8",
    pricePerHour: new Prisma.Decimal(120),
    isElectric: true,
    isAvailable: true,
    deliveryAvailable: false,
    createdAt: new Date("2026-06-10T00:00:00Z"),
    updatedAt: new Date("2026-06-10T00:00:00Z"),
    ...overrides,
  } as Vehicle;
}

beforeEach(() => vi.clearAllMocks());

describe("vehicleService.list", () => {
  it("maps Decimal price to number and echoes pagination", async () => {
    vi.mocked(vehicleRepository.findMany).mockResolvedValue({
      items: [{ ...makeVehicle(), owner: { name: "Nguyễn Văn An" } }],
      total: 1,
    });
    const result = await vehicleService.list({ page: 1, limit: 20 });
    expect(result.items[0]?.pricePerHour).toBe(120);
    expect(typeof result.items[0]?.pricePerHour).toBe("number");
    expect(result).toMatchObject({ total: 1, page: 1, limit: 20 });
  });
});

describe("vehicleService.getById", () => {
  it("returns the vehicle when found", async () => {
    vi.mocked(vehicleRepository.findByIdWithOwner).mockResolvedValue({
      ...makeVehicle(),
      owner: { name: "Nguyễn Văn An" },
    });
    expect((await vehicleService.getById("veh-1")).id).toBe("veh-1");
  });

  it("throws 404 when not found", async () => {
    vi.mocked(vehicleRepository.findByIdWithOwner).mockResolvedValue(null);
    await expect(vehicleService.getById("nope")).rejects.toMatchObject({
      status: 404,
      code: "VEHICLE_NOT_FOUND",
    });
  });
});

describe("vehicleService.nearby", () => {
  it("rounds distance and maps rows", async () => {
    vi.mocked(vehicleRepository.findNearby).mockResolvedValue([
      {
        id: "veh-1",
        ownerId: "owner-1",
        ownerName: "Nguyễn Văn An",
        type: VehicleType.CAR,
        title: "VF8",
        pricePerHour: 120,
        isElectric: true,
        isAvailable: true,
        deliveryAvailable: false,
        seats: null,
        doors: null,
        transmission: null,
        city: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        lat: 10.77,
        lng: 106.7,
        distanceMeters: 1234.6,
      },
    ]);
    const result = await vehicleService.nearby({
      lat: 10.77,
      lng: 106.7,
      radius: 5000,
      limit: 20,
    });
    expect(result[0]?.distanceMeters).toBe(1235);
  });
});

describe("vehicleService.update / remove ownership", () => {
  it("update succeeds for the owner", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(vehicleRepository.update).mockResolvedValue(
      makeVehicle({ title: "Updated" }),
    );
    vi.mocked(vehicleRepository.findByIdWithOwner).mockResolvedValue({
      ...makeVehicle({ title: "Updated" }),
      owner: { name: "Nguyễn Văn An" },
    });
    const result = await vehicleService.update("owner-1", "veh-1", {
      title: "Updated",
    });
    expect(result.title).toBe("Updated");
  });

  it("update throws 403 for a non-owner", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    await expect(
      vehicleService.update("intruder", "veh-1", { title: "x" }),
    ).rejects.toMatchObject({ status: 403, code: "FORBIDDEN" });
    expect(vehicleRepository.update).not.toHaveBeenCalled();
  });

  it("remove throws 404 when the vehicle is missing", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(null);
    await expect(vehicleService.remove("owner-1", "veh-1")).rejects.toBeInstanceOf(
      AppError,
    );
    expect(vehicleRepository.delete).not.toHaveBeenCalled();
  });
});
