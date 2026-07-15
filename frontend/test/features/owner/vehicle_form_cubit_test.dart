import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/presentation/cubit/vehicle_form_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/entities/price_quote.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:frontend/features/vehicle/domain/usecases/create_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/update_vehicle_usecase.dart';

const _created = Vehicle(
  id: 'v1',
  ownerId: 'owner1',
  type: 'CAR',
  title: 'Toyota Vios 2024',
  pricePerDay: 50000,
  isElectric: false,
  isAvailable: true,
  deliveryAvailable: false,
);

/// Fake cấu hình được — không chạm mạng.
class _FakeVehicleRepository implements VehicleRepository {
  Vehicle? createResult;
  Object? createError;
  Vehicle? updateResult;
  Object? updateError;

  @override
  Future<Vehicle> createVehicle({
    required String type,
    required String title,
    required double pricePerDay,
    required bool isElectric,
    required bool deliveryAvailable,
    required double lat,
    required double lng,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
  }) async {
    if (createError != null) throw createError!;
    return createResult!;
  }

  @override
  Future<Vehicle> updateVehicle(
    String id, {
    String? title,
    double? pricePerDay,
    bool? isElectric,
    bool? deliveryAvailable,
    bool? isAvailable,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
    double? lat,
    double? lng,
  }) async {
    if (updateError != null) throw updateError!;
    return updateResult!;
  }

  @override
  Future<void> deleteVehicle(String id) async {}

  @override
  Future<Vehicle> getVehicle(String id) => throw UnimplementedError();

  @override
  Future<VehicleAvailability> getAvailability(String id) =>
      throw UnimplementedError();

  @override
  Future<PriceQuote> getPriceQuote({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<Vehicle>> listVehicles({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    bool? mine,
    int page = 1,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<List<Vehicle>> nearbyVehicles({
    required double lat,
    required double lng,
    int radius = 5000,
    int limit = 20,
  }) => throw UnimplementedError();
}

VehicleFormCubit _build(_FakeVehicleRepository repo) => VehicleFormCubit(
  createVehicle: CreateVehicleUseCase(repo),
  updateVehicle: UpdateVehicleUseCase(repo),
);

Future<void> _act(VehicleFormCubit cubit) => cubit.create(
  type: 'CAR',
  title: 'Toyota Vios 2024',
  pricePerDay: 50000,
  isElectric: false,
  deliveryAvailable: false,
  lat: 21.0278,
  lng: 105.8342,
);

void main() {
  group('VehicleFormCubit', () {
    late _FakeVehicleRepository repo;

    setUp(() => repo = _FakeVehicleRepository());

    test('starts idle', () {
      expect(_build(repo).state, isA<VehicleFormIdle>());
    });

    blocTest<VehicleFormCubit, VehicleFormState>(
      'create success emits submitting then success with the vehicle',
      build: () {
        repo.createResult = _created;
        return _build(repo);
      },
      act: _act,
      expect: () => [
        isA<VehicleFormSubmitting>(),
        isA<VehicleFormSuccess>().having((s) => s.vehicle.id, 'id', 'v1'),
      ],
    );

    blocTest<VehicleFormCubit, VehicleFormState>(
      'create failure surfaces the API error message',
      build: () {
        repo.createError = const ApiException(
          'Chưa xác thực KYC',
          code: 'FORBIDDEN',
        );
        return _build(repo);
      },
      act: _act,
      expect: () => [
        isA<VehicleFormSubmitting>(),
        isA<VehicleFormError>()
            .having((s) => s.message, 'message', 'Chưa xác thực KYC'),
      ],
    );

    blocTest<VehicleFormCubit, VehicleFormState>(
      'update success emits submitting then success with the vehicle',
      build: () {
        repo.updateResult = _created;
        return _build(repo);
      },
      act: (cubit) => cubit.update(
        'v1',
        title: 'Toyota Vios 2024',
        pricePerDay: 60000,
        isElectric: false,
        deliveryAvailable: true,
      ),
      expect: () => [
        isA<VehicleFormSubmitting>(),
        isA<VehicleFormSuccess>().having((s) => s.vehicle.id, 'id', 'v1'),
      ],
    );

    blocTest<VehicleFormCubit, VehicleFormState>(
      'update failure surfaces the API error message',
      build: () {
        repo.updateError = const ApiException(
          'Không có quyền',
          code: 'FORBIDDEN',
        );
        return _build(repo);
      },
      act: (cubit) => cubit.update(
        'v1',
        title: 'Toyota Vios 2024',
        pricePerDay: 60000,
        isElectric: false,
        deliveryAvailable: true,
      ),
      expect: () => [
        isA<VehicleFormSubmitting>(),
        isA<VehicleFormError>()
            .having((s) => s.message, 'message', 'Không có quyền'),
      ],
    );
  });
}
