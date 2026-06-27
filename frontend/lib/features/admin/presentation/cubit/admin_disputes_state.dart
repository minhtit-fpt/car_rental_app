import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';

sealed class AdminDisputesState {
  const AdminDisputesState();
}

final class AdminDisputesLoading extends AdminDisputesState {
  const AdminDisputesLoading();
}

final class AdminDisputesLoaded extends AdminDisputesState {
  const AdminDisputesLoaded(this.items);
  final List<AdminDisputeItem> items;
}

final class AdminDisputesError extends AdminDisputesState {
  const AdminDisputesError(this.message);
  final String message;
}
