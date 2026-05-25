import 'package:go_router/go_router.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/screens/vehicle_detail_screen.dart';

final vehicleRoutes = [
  GoRoute(
    path: '/vehicles/:id',
    builder: (context, state) {
      final vehicle = state.extra as Vehicle;
      return VehicleDetailScreen(vehicle: vehicle);
    },
  ),
];
