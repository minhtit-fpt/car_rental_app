import type { VehicleLocation } from "@prisma/client";
import { prisma } from "@/db/prisma";

export interface InsertLocationData {
  vehicleId: string;
  bookingId: string | null;
  lat: number;
  lng: number;
  speedKmh?: number;
}

// Vị trí mới nhất của một xe đang trong chuyến (cho map admin).
export interface ActiveVehicleLocation {
  vehicleId: string;
  bookingId: string | null;
  title: string;
  lat: number;
  lng: number;
  speedKmh: number | null;
  recordedAt: Date;
}

export const trackingRepository = {
  insert(data: InsertLocationData): Promise<VehicleLocation> {
    return prisma.vehicleLocation.create({
      data: {
        vehicleId: data.vehicleId,
        bookingId: data.bookingId,
        lat: data.lat,
        lng: data.lng,
        speedKmh: data.speedKmh ?? null,
      },
    });
  },

  // Điểm mới nhất + (nếu trail>0) N điểm gần nhất, mới→cũ.
  findRecent(vehicleId: string, trail: number): Promise<VehicleLocation[]> {
    return prisma.vehicleLocation.findMany({
      where: { vehicleId },
      orderBy: { recordedAt: "desc" },
      take: Math.max(1, trail),
    });
  },

  // Vị trí mới nhất mỗi xe đang IN_PROGRESS. DISTINCT ON theo xe, chọn điểm mới
  // nhất; JOIN Booking (IN_PROGRESS) để chỉ lấy xe đang có chuyến chạy.
  findActiveLatest(): Promise<ActiveVehicleLocation[]> {
    return prisma.$queryRaw<ActiveVehicleLocation[]>`
      SELECT DISTINCT ON (l."vehicleId")
        l."vehicleId"    AS "vehicleId",
        l."bookingId"    AS "bookingId",
        v."title"        AS "title",
        l."lat"          AS "lat",
        l."lng"          AS "lng",
        l."speedKmh"     AS "speedKmh",
        l."recordedAt"   AS "recordedAt"
      FROM "VehicleLocation" l
      JOIN "Vehicle" v ON v."id" = l."vehicleId"
      JOIN "Booking" b
        ON b."vehicleId" = l."vehicleId" AND b."status" = 'IN_PROGRESS'
      ORDER BY l."vehicleId", l."recordedAt" DESC
    `;
  },
};
