import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';

abstract final class AdminRiskItemModel {
  static AdminRiskItem fromJson(Map<String, dynamic> json) {
    return AdminRiskItem(
      userId: json['userId'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      roles: (json['roles'] as List<dynamic>).cast<String>(),
      score: json['score'] as int,
      tier: json['tier'] as String,
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .map((r) => RiskReason(
                code: r['code'] as String,
                label: r['label'] as String,
              ))
          .toList(growable: false),
    );
  }
}
