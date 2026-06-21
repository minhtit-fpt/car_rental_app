import 'package:frontend/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Lấy danh sách xe đã lưu của user hiện tại (`GET /api/favorites`).
class ListFavoritesUseCase {
  const ListFavoritesUseCase(this._repository);

  final FavoriteRepository _repository;

  Future<List<Vehicle>> call() => _repository.list();
}
