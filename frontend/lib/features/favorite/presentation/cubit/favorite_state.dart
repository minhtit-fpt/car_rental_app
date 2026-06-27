import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Trạng thái tải của màn "Xe đã lưu".
enum FavoriteStatus { initial, loading, loaded, error }

/// Trạng thái yêu thích dùng chung toàn app:
/// - [favoriteIds] đồng bộ icon tim ở card / detail / màn saved.
/// - [savedVehicles] + [status] phục vụ riêng màn "Xe đã lưu".
class FavoriteState {
  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.favoriteIds = const {},
    this.savedVehicles = const [],
    this.errorMessage,
  });

  final FavoriteStatus status;
  final Set<String> favoriteIds;
  final List<Vehicle> savedVehicles;
  final String? errorMessage;

  bool isFavorite(String vehicleId) => favoriteIds.contains(vehicleId);

  FavoriteState copyWith({
    FavoriteStatus? status,
    Set<String>? favoriteIds,
    List<Vehicle>? savedVehicles,
    String? errorMessage,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      savedVehicles: savedVehicles ?? this.savedVehicles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
