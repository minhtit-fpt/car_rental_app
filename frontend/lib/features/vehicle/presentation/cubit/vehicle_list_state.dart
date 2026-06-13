import 'package:equatable/equatable.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

sealed class VehicleListState extends Equatable {
  const VehicleListState();

  @override
  List<Object?> get props => [];
}

final class VehicleListLoading extends VehicleListState {
  const VehicleListLoading();
}

final class VehicleListLoaded extends VehicleListState {
  const VehicleListLoaded({
    required this.items,
    this.type,
    this.electricOnly = false,
  });

  final List<Vehicle> items;
  final VehicleType? type;
  final bool electricOnly;

  @override
  List<Object?> get props => [items, type, electricOnly];
}

final class VehicleListError extends VehicleListState {
  const VehicleListError({
    required this.message,
    this.type,
    this.electricOnly = false,
  });

  final String message;
  final VehicleType? type;
  final bool electricOnly;

  @override
  List<Object?> get props => [message, type, electricOnly];
}
