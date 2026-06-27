import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';

abstract final class KycStatusInfoModel {
  static KycStatusInfo fromJson(Map<String, dynamic> json) => KycStatusInfo(
    status: json['status'] as String,
    rejectReason: json['rejectReason'] as String?,
    reviewedAt: _parse(json['reviewedAt']),
    submittedAt: _parse(json['submittedAt']),
  );

  static DateTime? _parse(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
