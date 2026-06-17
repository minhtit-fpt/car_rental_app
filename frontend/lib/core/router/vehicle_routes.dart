import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:frontend/features/vehicle/domain/usecases/get_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/presentation/screens/vehicle_detail_screen.dart';

final vehicleRoutes = [
  GoRoute(
    path: '/vehicles/:id',
    builder: (context, state) {
      // Điều hướng từ danh sách truyền sẵn entity qua `extra` (không gọi lại
      // API). Deep-link chỉ có id → tự nạp bằng usecase.
      final extra = state.extra;
      if (extra is Vehicle) {
        return VehicleDetailScreen(vehicle: extra);
      }
      return _VehicleDetailLoader(id: state.pathParameters['id']!);
    },
  ),
];

/// Nạp chi tiết xe theo id khi không có entity truyền kèm (deep-link).
class _VehicleDetailLoader extends StatefulWidget {
  const _VehicleDetailLoader({required this.id});

  final String id;

  @override
  State<_VehicleDetailLoader> createState() => _VehicleDetailLoaderState();
}

class _VehicleDetailLoaderState extends State<_VehicleDetailLoader> {
  late final Future<Vehicle> _future = GetVehicleUseCase(
    sl<VehicleRepository>(),
  ).call(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Vehicle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ApiException
              ? error.message
              : 'Không tải được thông tin xe';
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: AppColors.surface),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          );
        }
        return VehicleDetailScreen(vehicle: snapshot.data!);
      },
    );
  }
}
