import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';

sealed class AdminBookingDetailState {
  const AdminBookingDetailState();
}

final class AdminBookingDetailLoading extends AdminBookingDetailState {
  const AdminBookingDetailLoading();
}

final class AdminBookingDetailError extends AdminBookingDetailState {
  const AdminBookingDetailError(this.message);
  final String message;
}

final class AdminBookingDetailLoaded extends AdminBookingDetailState {
  const AdminBookingDetailLoaded(
    this.detail, {
    this.submitting = false,
    this.refundError,
    this.refunded = false,
  });

  final AdminBookingDetail detail;
  final bool submitting;
  final String? refundError;

  /// true sau khi hoàn tiền thành công → màn hiện xác nhận + làm mới.
  final bool refunded;

  AdminBookingDetailLoaded copyWith({
    AdminBookingDetail? detail,
    bool? submitting,
    String? refundError,
    bool? refunded,
  }) {
    return AdminBookingDetailLoaded(
      detail ?? this.detail,
      submitting: submitting ?? this.submitting,
      refundError: refundError,
      refunded: refunded ?? this.refunded,
    );
  }
}
