import { randomUUID } from "node:crypto";
import { Prisma, type Vehicle, type VehicleType } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Vehicle. Cột `location` là geography(Point,4326) — Prisma
// không đọc/ghi được qua client thường, nên insert/nearby dùng raw SQL PostGIS.
// findMany/findById vẫn dùng Prisma (Prisma tự bỏ qua cột Unsupported).

export interface VehicleListFilters {
  type?: VehicleType;
  isElectric?: boolean;
  available?: boolean;
  minPrice?: number;
  maxPrice?: number;
  ownerId?: string;
  page: number;
  limit: number;
}

export interface CreateVehicleData {
  ownerId: string;
  type: VehicleType;
  title: string;
  pricePerHour: number;
  isElectric: boolean;
  deliveryAvailable: boolean;
  isAvailable: boolean;
  seats?: number;
  doors?: number;
  transmission?: string;
  city?: string;
  lat: number;
  lng: number;
}

export interface UpdateVehicleData {
  title?: string;
  pricePerHour?: number;
  isElectric?: boolean;
  deliveryAvailable?: boolean;
  isAvailable?: boolean;
  seats?: number;
  doors?: number;
  transmission?: string;
  city?: string;
  lat?: number;
  lng?: number;
}

export interface NearbyParams {
  lat: number;
  lng: number;
  radius: number;
  limit: number;
}

// Shape thô trả về từ raw query nearby (đã trích lat/lng/khoảng cách).
export interface NearbyRow {
  id: string;
  ownerId: string;
  ownerName: string | null;
  type: VehicleType;
  title: string;
  pricePerHour: number;
  isElectric: boolean;
  isAvailable: boolean;
  deliveryAvailable: boolean;
  seats: number | null;
  doors: number | null;
  transmission: string | null;
  city: string | null;
  createdAt: Date;
  updatedAt: Date;
  lat: number;
  lng: number;
  distanceMeters: number;
}

// Vehicle kèm tên chủ xe (cho list/getById). `owner` chỉ select trường hiển thị.
const ownerNameInclude = { owner: { select: { name: true } } } as const;
export type VehicleWithOwner = Vehicle & { owner: { name: string | null } };

function buildWhere(f: VehicleListFilters): Prisma.VehicleWhereInput {
  return {
    ...(f.type && { type: f.type }),
    ...(f.ownerId && { ownerId: f.ownerId }),
    ...(f.isElectric !== undefined && { isElectric: f.isElectric }),
    ...(f.available !== undefined && { isAvailable: f.available }),
    ...((f.minPrice !== undefined || f.maxPrice !== undefined) && {
      pricePerHour: {
        ...(f.minPrice !== undefined && { gte: f.minPrice }),
        ...(f.maxPrice !== undefined && { lte: f.maxPrice }),
      },
    }),
  };
}

export const vehicleRepository = {
  async findMany(
    f: VehicleListFilters,
  ): Promise<{ items: VehicleWithOwner[]; total: number }> {
    const where = buildWhere(f);
    const [items, total] = await Promise.all([
      prisma.vehicle.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (f.page - 1) * f.limit,
        take: f.limit,
        include: ownerNameInclude,
      }),
      prisma.vehicle.count({ where }),
    ]);
    return { items, total };
  },

  findById(id: string): Promise<Vehicle | null> {
    return prisma.vehicle.findUnique({ where: { id } });
  },

  findByIdWithOwner(id: string): Promise<VehicleWithOwner | null> {
    return prisma.vehicle.findUnique({
      where: { id },
      include: ownerNameInclude,
    });
  },

  async create(data: CreateVehicleData): Promise<Vehicle> {
    const id = randomUUID();
    await prisma.$executeRaw(Prisma.sql`
      INSERT INTO "Vehicle"
        ("id","ownerId","type","title","pricePerHour","isElectric",
         "isAvailable","deliveryAvailable","seats","doors","transmission",
         "city","location","createdAt","updatedAt")
      VALUES (
        ${id}::uuid, ${data.ownerId}::uuid, ${data.type}::"VehicleType",
        ${data.title}, ${data.pricePerHour}, ${data.isElectric},
        ${data.isAvailable}, ${data.deliveryAvailable},
        ${data.seats ?? null}, ${data.doors ?? null},
        ${data.transmission ?? null}, ${data.city ?? null},
        ST_SetSRID(ST_MakePoint(${data.lng}, ${data.lat}), 4326)::geography,
        now(), now()
      )
    `);
    const created = await this.findById(id);
    if (!created) {
      throw new Error("Vehicle insert succeeded but row not found");
    }
    return created;
  },

  async update(id: string, data: UpdateVehicleData): Promise<Vehicle> {
    const scalar: Prisma.VehicleUpdateInput = {
      ...(data.title !== undefined && { title: data.title }),
      ...(data.pricePerHour !== undefined && {
        pricePerHour: data.pricePerHour,
      }),
      ...(data.isElectric !== undefined && { isElectric: data.isElectric }),
      ...(data.deliveryAvailable !== undefined && {
        deliveryAvailable: data.deliveryAvailable,
      }),
      ...(data.isAvailable !== undefined && { isAvailable: data.isAvailable }),
      ...(data.seats !== undefined && { seats: data.seats }),
      ...(data.doors !== undefined && { doors: data.doors }),
      ...(data.transmission !== undefined && {
        transmission: data.transmission,
      }),
      ...(data.city !== undefined && { city: data.city }),
    };
    if (Object.keys(scalar).length > 0) {
      await prisma.vehicle.update({ where: { id }, data: scalar });
    }
    if (data.lat !== undefined && data.lng !== undefined) {
      await prisma.$executeRaw(Prisma.sql`
        UPDATE "Vehicle"
        SET "location" =
              ST_SetSRID(ST_MakePoint(${data.lng}, ${data.lat}), 4326)::geography,
            "updatedAt" = now()
        WHERE "id" = ${id}::uuid
      `);
    }
    const updated = await this.findById(id);
    if (!updated) {
      throw new Error("Vehicle update succeeded but row not found");
    }
    return updated;
  },

  async delete(id: string): Promise<void> {
    await prisma.vehicle.delete({ where: { id } });
  },

  // Xe gần vị trí, dùng ST_DWithin (geography → mét) + GIST index.
  findNearby(p: NearbyParams): Promise<NearbyRow[]> {
    return prisma.$queryRaw<NearbyRow[]>(Prisma.sql`
      SELECT
        v."id", v."ownerId", u."name" AS "ownerName", v."type", v."title",
        v."pricePerHour"::float8 AS "pricePerHour",
        v."isElectric", v."isAvailable", v."deliveryAvailable",
        v."seats", v."doors", v."transmission", v."city",
        v."createdAt", v."updatedAt",
        ST_Y(v."location"::geometry) AS "lat",
        ST_X(v."location"::geometry) AS "lng",
        ST_Distance(
          v."location",
          ST_SetSRID(ST_MakePoint(${p.lng}, ${p.lat}), 4326)::geography
        ) AS "distanceMeters"
      FROM "Vehicle" v
      JOIN "User" u ON u."id" = v."ownerId"
      WHERE v."isAvailable" = true
        AND ST_DWithin(
          v."location",
          ST_SetSRID(ST_MakePoint(${p.lng}, ${p.lat}), 4326)::geography,
          ${p.radius}
        )
      ORDER BY "distanceMeters" ASC
      LIMIT ${p.limit}
    `);
  },
};
