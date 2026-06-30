import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';

sealed class AdminBookingsState {
  const AdminBookingsState();
}

final class AdminBookingsLoading extends AdminBookingsState {
  const AdminBookingsLoading();
}

final class AdminBookingsLoaded extends AdminBookingsState {
  const AdminBookingsLoaded(this.items, {this.status});

  final List<AdminBookingItem> items;

  /// Bộ lọc trạng thái đang áp dụng (null = tất cả).
  final String? status;
}

final class AdminBookingsError extends AdminBookingsState {
  const AdminBookingsError(this.message);
  final String message;
}
