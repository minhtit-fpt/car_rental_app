import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';

abstract final class AdminUserItemModel {
  static AdminUserItem fromJson(Map<String, dynamic> json) => AdminUserItem(
    id: json['id'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    roles: (json['roles'] as List<dynamic>)
        .map((e) => e as String)
        .toList(growable: false),
    kycStatus: json['kycStatus'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
