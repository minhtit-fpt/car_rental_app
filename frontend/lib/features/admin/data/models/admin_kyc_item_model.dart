import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';

abstract final class AdminKycItemModel {
  static AdminKycItem fromJson(Map<String, dynamic> json) => AdminKycItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        status: json['status'] as String,
        submittedAt: DateTime.parse(json['submittedAt'] as String),
      );
}
