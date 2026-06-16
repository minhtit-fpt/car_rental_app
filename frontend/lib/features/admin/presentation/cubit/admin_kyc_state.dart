import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';

sealed class AdminKycState {
  const AdminKycState();
}

final class AdminKycLoading extends AdminKycState {
  const AdminKycLoading();
}

final class AdminKycLoaded extends AdminKycState {
  const AdminKycLoaded(this.items);
  final List<AdminKycItem> items;
}

final class AdminKycError extends AdminKycState {
  const AdminKycError(this.message);
  final String message;
}
