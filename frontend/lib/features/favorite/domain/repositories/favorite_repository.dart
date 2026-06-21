import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Hợp đồng domain cho xe yêu thích (`/api/favorites`).
abstract interface class FavoriteRepository {
  /// `GET /api/favorites` — danh sách xe đã lưu của user hiện tại.
  Future<List<Vehicle>> list();

  /// `POST /api/favorites/:vehicleId` — thêm xe vào yêu thích.
  Future<void> add(String vehicleId);

  /// `DELETE /api/favorites/:vehicleId` — bỏ xe khỏi yêu thích.
  Future<void> remove(String vehicleId);
}
