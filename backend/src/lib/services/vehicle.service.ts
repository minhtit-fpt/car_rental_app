import type { Vehicle, VehicleType } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import {
  vehicleRepository,
  type NearbyRow,
  type VehicleListFilters,
} from "@/lib/repositories/vehicle.repository";
import type {
  CreateVehicleInput,
  UpdateVehicleInput,
} from "@/lib/validators/vehicle.validator";

export interface PublicVehicle {
  id: string;
  ownerId: string;
  type: VehicleType;
  title: string;
  pricePerHour: number;
  isElectric: boolean;
  isAvailable: boolean;
  deliveryAvailable: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface NearbyVehicle extends PublicVehicle {
  lat: number;
  lng: number;
  distanceMeters: number;
}

export interface VehicleListResult {
  items: PublicVehicle[];
  total: number;
  page: number;
  limit: number;
}

// Decimal của Prisma → number cho JSON response.
function toPublicVehicle(v: Vehicle): PublicVehicle {
  return {
    id: v.id,
    ownerId: v.ownerId,
    type: v.type,
    title: v.title,
    pricePerHour: Number(v.pricePerHour),
    isElectric: v.isElectric,
    isAvailable: v.isAvailable,
    deliveryAvailable: v.deliveryAvailable,
    createdAt: v.createdAt,
    updatedAt: v.updatedAt,
  };
}

function toNearbyVehicle(row: NearbyRow): NearbyVehicle {
  return {
    id: row.id,
    ownerId: row.ownerId,
    type: row.type,
    title: row.title,
    pricePerHour: Number(row.pricePerHour),
    isElectric: row.isElectric,
    isAvailable: row.isAvailable,
    deliveryAvailable: row.deliveryAvailable,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lat: row.lat,
    lng: row.lng,
    distanceMeters: Math.round(row.distanceMeters),
  };
}

async function loadOwned(id: string, userId: string): Promise<Vehicle> {
  const existing = await vehicleRepository.findById(id);
  if (!existing) {
    throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
  }
  if (existing.ownerId !== userId) {
    throw new AppError(403, "FORBIDDEN", "Bạn không phải chủ xe này");
  }
  return existing;
}

export const vehicleService = {
  async list(filters: VehicleListFilters): Promise<VehicleListResult> {
    const { items, total } = await vehicleRepository.findMany(filters);
    return {
      items: items.map(toPublicVehicle),
      total,
      page: filters.page,
      limit: filters.limit,
    };
  },

  async getById(id: string): Promise<PublicVehicle> {
    const v = await vehicleRepository.findById(id);
    if (!v) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }
    return toPublicVehicle(v);
  },

  async nearby(params: {
    lat: number;
    lng: number;
    radius: number;
    limit: number;
  }): Promise<NearbyVehicle[]> {
    const rows = await vehicleRepository.findNearby(params);
    return rows.map(toNearbyVehicle);
  },

  async create(
    ownerId: string,
    input: CreateVehicleInput,
  ): Promise<PublicVehicle> {
    const v = await vehicleRepository.create({ ownerId, ...input });
    return toPublicVehicle(v);
  },

  async update(
    userId: string,
    id: string,
    input: UpdateVehicleInput,
  ): Promise<PublicVehicle> {
    await loadOwned(id, userId);
    const v = await vehicleRepository.update(id, input);
    return toPublicVehicle(v);
  },

  async remove(userId: string, id: string): Promise<void> {
    await loadOwned(id, userId);
    await vehicleRepository.delete(id);
  },
};
