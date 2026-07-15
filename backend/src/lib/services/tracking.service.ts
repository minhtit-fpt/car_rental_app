import { UserRole } from "@prisma/client";
import type { AccessTokenClaims } from "@/lib/auth/jwt";
import { AppError } from "@/lib/errors/app-error";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import {
  trackingRepository,
  type ActiveVehicleLocation,
} from "@/lib/repositories/tracking.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import type { IngestLocationInput } from "@/lib/validators/tracking.validator";

export interface TrackingPoint {
  lat: number;
  lng: number;
  speedKmh: number | null;
  recordedAt: Date;
}

export interface TrackingSnapshot {
  vehicleId: string;
  bookingId: string | null;
  latest: TrackingPoint;
  trail: TrackingPoint[]; // cũ→mới, để vẽ polyline
}

function toPoint(row: {
  lat: number;
  lng: number;
  speedKmh: number | null;
  recordedAt: Date;
}): TrackingPoint {
  return {
    lat: row.lat,
    lng: row.lng,
    speedKmh: row.speedKmh,
    recordedAt: row.recordedAt,
  };
}

export const trackingService = {
  // Ingest 1 điểm. Gọi từ route sau khi đã xác thực device key. Gán bookingId
  // của chuyến IN_PROGRESS hiện tại (nếu có) để replay theo chuyến.
  async ingest(vehicleId: string, input: IngestLocationInput): Promise<void> {
    const vehicle = await vehicleRepository.findById(vehicleId);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }
    const booking =
      await bookingRepository.findInProgressByVehicle(vehicleId);
    await trackingRepository.insert({
      vehicleId,
      bookingId: booking?.id ?? null,
      lat: input.lat,
      lng: input.lng,
      speedKmh: input.speedKmh,
    });
  },

  // Vị trí realtime của xe. Chỉ xem được khi xe đang trong chuyến (IN_PROGRESS)
  // và người xem là admin / chủ xe / người thuê của chuyến đó. Ngoài chuyến → 403.
  async getSnapshot(
    claims: AccessTokenClaims,
    vehicleId: string,
    trail: number,
  ): Promise<TrackingSnapshot> {
    const vehicle = await vehicleRepository.findById(vehicleId);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }
    const booking =
      await bookingRepository.findInProgressByVehicle(vehicleId);
    if (!booking) {
      throw new AppError(
        403,
        "TRACKING_UNAVAILABLE",
        "Xe không trong chuyến — không có dữ liệu vị trí",
      );
    }
    const isAdmin = claims.roles.includes(UserRole.ADMIN);
    const isOwner = claims.sub === vehicle.ownerId;
    const isRenter = claims.sub === booking.renterId;
    if (!isAdmin && !isOwner && !isRenter) {
      throw new AppError(403, "FORBIDDEN", "Bạn không có quyền xem vị trí xe này");
    }

    const recent = await trackingRepository.findRecent(vehicleId, trail);
    if (recent.length === 0) {
      throw new AppError(
        404,
        "TRACKING_NO_DATA",
        "Chưa có dữ liệu vị trí cho xe này",
      );
    }
    // recent là mới→cũ; latest = phần tử đầu, trail đảo lại cũ→mới cho polyline.
    return {
      vehicleId,
      bookingId: booking.id,
      latest: toPoint(recent[0]),
      trail: recent.slice().reverse().map(toPoint),
    };
  },

  // Map admin: vị trí mới nhất của mọi xe đang chạy.
  async listActive(
    claims: AccessTokenClaims,
  ): Promise<ActiveVehicleLocation[]> {
    if (!claims.roles.includes(UserRole.ADMIN)) {
      throw new AppError(403, "FORBIDDEN", "Chỉ ADMIN xem được bản đồ này");
    }
    return trackingRepository.findActiveLatest();
  },
};
