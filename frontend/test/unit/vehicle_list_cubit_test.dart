import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/domain/vehicle_exception.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';

class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

void main() {
  late MockGetVehiclesUseCase getVehicles;

  const vehicle = Vehicle(
    id: 'veh-1',
    ownerId: 'owner-1',
    type: VehicleType.car,
    title: 'Vinfast VF8',
    pricePerHour: 120,
    isElectric: true,
    isAvailable: true,
    deliveryAvailable: false,
  );

  setUp(() => getVehicles = MockGetVehiclesUseCase());

  VehicleListCubit build() => VehicleListCubit(getVehicles);

  blocTest<VehicleListCubit, VehicleListState>(
    'load emits [loading, loaded] with fetched items',
    setUp: () => when(
      () => getVehicles(
        type: any(named: 'type'),
        isElectric: any(named: 'isElectric'),
      ),
    ).thenAnswer((_) async => [vehicle]),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const VehicleListLoading(),
      const VehicleListLoaded(items: [vehicle]),
    ],
  );

  blocTest<VehicleListCubit, VehicleListState>(
    'setType forwards the type filter and reflects it in state',
    setUp: () => when(
      () => getVehicles(
        type: any(named: 'type'),
        isElectric: any(named: 'isElectric'),
      ),
    ).thenAnswer((_) async => [vehicle]),
    build: build,
    act: (cubit) => cubit.setType(VehicleType.motorbike),
    expect: () => [
      const VehicleListLoading(),
      const VehicleListLoaded(items: [vehicle], type: VehicleType.motorbike),
    ],
    verify: (_) => verify(
      () => getVehicles(type: VehicleType.motorbike, isElectric: null),
    ).called(1),
  );

  blocTest<VehicleListCubit, VehicleListState>(
    'toggleElectric passes isElectric=true',
    setUp: () => when(
      () => getVehicles(
        type: any(named: 'type'),
        isElectric: any(named: 'isElectric'),
      ),
    ).thenAnswer((_) async => const []),
    build: build,
    act: (cubit) => cubit.toggleElectric(true),
    expect: () => [
      const VehicleListLoading(),
      const VehicleListLoaded(items: [], electricOnly: true),
    ],
    verify: (_) =>
        verify(() => getVehicles(type: null, isElectric: true)).called(1),
  );

  blocTest<VehicleListCubit, VehicleListState>(
    'load emits [loading, error] on failure',
    setUp: () => when(
      () => getVehicles(
        type: any(named: 'type'),
        isElectric: any(named: 'isElectric'),
      ),
    ).thenThrow(const VehicleException('boom')),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const VehicleListLoading(),
      const VehicleListError(message: 'boom'),
    ],
  );
}
