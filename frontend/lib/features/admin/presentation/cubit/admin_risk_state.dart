import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';

sealed class AdminRiskState {
  const AdminRiskState();
}

final class AdminRiskLoading extends AdminRiskState {
  const AdminRiskLoading();
}

final class AdminRiskLoaded extends AdminRiskState {
  const AdminRiskLoaded(
    this.items, {
    this.explanations = const {},
    this.explainingUserId,
  });

  final List<AdminRiskItem> items;

  /// userId → lời giải thích AI (hoặc thông báo offline). 5b-tail.
  final Map<String, String> explanations;

  /// userId đang chờ AI giải thích (để hiện spinner trên đúng thẻ).
  final String? explainingUserId;

  AdminRiskLoaded copyWith({
    Map<String, String>? explanations,
    String? explainingUserId,
  }) {
    return AdminRiskLoaded(
      items,
      explanations: explanations ?? this.explanations,
      explainingUserId: explainingUserId,
    );
  }
}

final class AdminRiskError extends AdminRiskState {
  const AdminRiskError(this.message);
  final String message;
}
