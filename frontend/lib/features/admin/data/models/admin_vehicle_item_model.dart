import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';

abstract final class AdminVehicleItemModel {
  static AdminVehicleItem fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>;
    return AdminVehicleItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      isElectric: json['isElectric'] as bool,
      city: json['city'] as String?,
      approvalStatus: json['approvalStatus'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ownerId: owner['id'] as String,
      ownerPhone: owner['phone'] as String,
      ownerEmail: owner['email'] as String?,
    );
  }
}
