import { AppError } from "@/lib/errors/app-error";
import { favoriteRepository } from "@/lib/repositories/favorite.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import {
  toPublicVehicle,
  type PublicVehicle,
} from "@/lib/services/vehicle.service";

export interface FavoriteToggleResult {
  vehicleId: string;
  favorited: boolean;
}

export const favoriteService = {
  // Danh sách xe đã lưu của user hiện tại (mới lưu trước).
  async list(userId: string): Promise<PublicVehicle[]> {
    const rows = await favoriteRepository.findByUser(userId);
    return rows.map((r) => toPublicVehicle(r.vehicle, r.vehicle.owner.name));
  },

  // Thêm xe vào yêu thích. 404 nếu xe không tồn tại. Idempotent.
  async add(userId: string, vehicleId: string): Promise<FavoriteToggleResult> {
    const vehicle = await vehicleRepository.findById(vehicleId);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }
    await favoriteRepository.add(userId, vehicleId);
    return { vehicleId, favorited: true };
  },

  // Bỏ xe khỏi yêu thích. Idempotent (không lỗi nếu chưa lưu).
  async remove(
    userId: string,
    vehicleId: string,
  ): Promise<FavoriteToggleResult> {
    await favoriteRepository.remove(userId, vehicleId);
    return { vehicleId, favorited: false };
  },
};
