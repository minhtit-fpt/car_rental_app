import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/favorite/domain/usecases/list_favorites_usecase.dart';
import 'package:frontend/features/favorite/domain/usecases/toggle_favorite_usecase.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_state.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

export 'package:frontend/features/favorite/presentation/cubit/favorite_state.dart';

/// Cubit yêu thích — singleton dùng chung toàn app để icon tim đồng bộ giữa
/// card, màn chi tiết và màn "Xe đã lưu".
class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit({
    required ListFavoritesUseCase listFavorites,
    required ToggleFavoriteUseCase toggleFavorite,
  }) : _listFavorites = listFavorites,
       _toggleFavorite = toggleFavorite,
       super(const FavoriteState());

  final ListFavoritesUseCase _listFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;

  /// Tải danh sách xe đã lưu (giữ nguyên các id hiện có trong lúc tải lại).
  Future<void> load() async {
    emit(state.copyWith(status: FavoriteStatus.loading));
    try {
      final vehicles = await _listFavorites();
      emit(
        FavoriteState(
          status: FavoriteStatus.loaded,
          savedVehicles: vehicles,
          favoriteIds: vehicles.map((v) => v.id).toSet(),
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: FavoriteStatus.error, errorMessage: e.message));
    }
  }

  /// Bật/tắt yêu thích với optimistic update; tự rollback khi API lỗi.
  /// Trả về `true` nếu thành công, `false` nếu đã rollback (để UI báo lỗi).
  Future<bool> toggle(Vehicle vehicle) async {
    final previousIds = state.favoriteIds;
    final previousSaved = state.savedVehicles;
    final wasFavorite = previousIds.contains(vehicle.id);

    final nextIds = {...previousIds};
    final nextSaved = [...previousSaved];
    if (wasFavorite) {
      nextIds.remove(vehicle.id);
      nextSaved.removeWhere((v) => v.id == vehicle.id);
    } else {
      nextIds.add(vehicle.id);
      nextSaved.insert(0, vehicle);
    }
    emit(state.copyWith(favoriteIds: nextIds, savedVehicles: nextSaved));

    try {
      await _toggleFavorite(vehicleId: vehicle.id, add: !wasFavorite);
      return true;
    } on ApiException {
      // Rollback về trạng thái trước khi bấm.
      emit(
        state.copyWith(
          favoriteIds: previousIds,
          savedVehicles: previousSaved,
        ),
      );
      return false;
    }
  }

  /// Xoá toàn bộ trạng thái khi đăng xuất.
  void clear() => emit(const FavoriteState());
}
