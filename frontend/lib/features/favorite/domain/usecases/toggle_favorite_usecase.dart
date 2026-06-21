import 'package:frontend/features/favorite/domain/repositories/favorite_repository.dart';

/// Bật/tắt yêu thích cho một xe. [add] = true → thêm; false → bỏ.
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final FavoriteRepository _repository;

  Future<void> call({required String vehicleId, required bool add}) =>
      add ? _repository.add(vehicleId) : _repository.remove(vehicleId);
}
