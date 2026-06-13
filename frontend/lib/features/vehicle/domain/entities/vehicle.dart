import 'package:equatable/equatable.dart';

/// Loại xe, khớp enum backend (CAR|MOTORBIKE|BICYCLE).
enum VehicleType { car, motorbike, bicycle }

VehicleType vehicleTypeFromWire(String? value) => switch (value) {
      'MOTORBIKE' => VehicleType.motorbike,
      'BICYCLE' => VehicleType.bicycle,
      _ => VehicleType.car,
    };

extension VehicleTypeX on VehicleType {
  String get wireValue => switch (this) {
        VehicleType.car => 'CAR',
        VehicleType.motorbike => 'MOTORBIKE',
        VehicleType.bicycle => 'BICYCLE',
      };

  String get label => switch (this) {
        VehicleType.car => 'Ô tô',
        VehicleType.motorbike => 'Xe máy',
        VehicleType.bicycle => 'Xe đạp',
      };

  String get emoji => switch (this) {
        VehicleType.car => '🚗',
        VehicleType.motorbike => '🏍️',
        VehicleType.bicycle => '🚲',
      };
}

/// Xe — khớp dữ liệu backend (MVP này chưa có rating/năm/owner-name).
class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.pricePerHour,
    required this.isElectric,
    required this.isAvailable,
    required this.deliveryAvailable,
  });

  final String id;
  final String ownerId;
  final VehicleType type;
  final String title;
  final double pricePerHour;
  final bool isElectric;
  final bool isAvailable;
  final bool deliveryAvailable;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        type,
        title,
        pricePerHour,
        isElectric,
        isAvailable,
        deliveryAvailable,
      ];
}
