import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';

sealed class AdminRiskState {
  const AdminRiskState();
}

final class AdminRiskLoading extends AdminRiskState {
  const AdminRiskLoading();
}

final class AdminRiskLoaded extends AdminRiskState {
  const AdminRiskLoaded(this.items);
  final List<AdminRiskItem> items;
}

final class AdminRiskError extends AdminRiskState {
  const AdminRiskError(this.message);
  final String message;
}
