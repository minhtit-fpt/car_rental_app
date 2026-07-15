import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:frontend/features/favorite/domain/usecases/list_favorites_usecase.dart';
import 'package:frontend/features/favorite/domain/usecases/toggle_favorite_usecase.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

Vehicle _vehicle(String id) => Vehicle(
  id: id,
  ownerId: 'o1',
  type: 'CAR',
  title: 'Xe $id',
  pricePerDay: 100,
  isElectric: false,
  isAvailable: true,
  deliveryAvailable: false,
);

/// Fake cấu hình được — không chạm mạng.
class _FakeFavoriteRepository implements FavoriteRepository {
  List<Vehicle> listResult = const [];
  Object? listError;
  Object? toggleError;
  final added = <String>[];
  final removed = <String>[];

  @override
  Future<List<Vehicle>> list() async {
    if (listError != null) throw listError!;
    return listResult;
  }

  @override
  Future<void> add(String vehicleId) async {
    if (toggleError != null) throw toggleError!;
    added.add(vehicleId);
  }

  @override
  Future<void> remove(String vehicleId) async {
    if (toggleError != null) throw toggleError!;
    removed.add(vehicleId);
  }
}

FavoriteCubit _build(_FakeFavoriteRepository repo) => FavoriteCubit(
  listFavorites: ListFavoritesUseCase(repo),
  toggleFavorite: ToggleFavoriteUseCase(repo),
);

void main() {
  group('FavoriteCubit', () {
    late _FakeFavoriteRepository repo;

    setUp(() => repo = _FakeFavoriteRepository());

    blocTest<FavoriteCubit, FavoriteState>(
      'load success emits loading then loaded with favorite ids',
      build: () {
        repo.listResult = [_vehicle('v1'), _vehicle('v2')];
        return _build(repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<FavoriteState>().having(
          (s) => s.status,
          'status',
          FavoriteStatus.loading,
        ),
        isA<FavoriteState>()
            .having((s) => s.status, 'status', FavoriteStatus.loaded)
            .having((s) => s.favoriteIds, 'ids', {'v1', 'v2'})
            .having((s) => s.savedVehicles.length, 'count', 2),
      ],
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'load failure surfaces the API error message',
      build: () {
        repo.listError = const ApiException('Lỗi máy chủ', code: 'SERVER_ERROR');
        return _build(repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<FavoriteState>().having(
          (s) => s.status,
          'status',
          FavoriteStatus.loading,
        ),
        isA<FavoriteState>()
            .having((s) => s.status, 'status', FavoriteStatus.error)
            .having((s) => s.errorMessage, 'message', 'Lỗi máy chủ'),
      ],
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'toggle adds id optimistically and keeps it on success',
      build: () => _build(repo),
      seed: () => const FavoriteState(status: FavoriteStatus.loaded),
      act: (cubit) => cubit.toggle(_vehicle('v1')),
      expect: () => [
        isA<FavoriteState>()
            .having((s) => s.favoriteIds, 'ids', {'v1'})
            .having((s) => s.savedVehicles.length, 'count', 1),
      ],
      verify: (_) => expect(repo.added, ['v1']),
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'toggle rolls back when the API fails',
      build: () {
        repo.toggleError = const ApiException('Lỗi');
        return _build(repo);
      },
      seed: () => FavoriteState(
        status: FavoriteStatus.loaded,
        favoriteIds: const {'v1'},
        savedVehicles: [_vehicle('v1')],
      ),
      act: (cubit) => cubit.toggle(_vehicle('v1')),
      expect: () => [
        // Optimistic: bỏ khỏi danh sách ngay.
        isA<FavoriteState>().having((s) => s.favoriteIds, 'ids', <String>{}),
        // Rollback: khôi phục sau khi API lỗi.
        isA<FavoriteState>().having((s) => s.favoriteIds, 'ids', {'v1'}),
      ],
    );

    test('toggle returns true on success and false on failure', () async {
      final okCubit = _build(repo);
      expect(await okCubit.toggle(_vehicle('v1')), isTrue);
      await okCubit.close();

      repo.toggleError = const ApiException('Lỗi');
      final failCubit = _build(repo);
      expect(await failCubit.toggle(_vehicle('v2')), isFalse);
      await failCubit.close();
    });
  });
}
