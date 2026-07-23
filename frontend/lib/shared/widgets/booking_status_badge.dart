import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Badge trạng thái đơn đặt — dùng chung cho danh sách chuyến của người
/// thuê và chủ xe.
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      BookingStatus.pendingPayment => (
        l10n.bookingStatusPendingPayment,
        AppColors.accent,
      ),
      BookingStatus.awaitingOwner => (
        l10n.bookingStatusAwaitingOwner,
        AppColors.warning,
      ),
      BookingStatus.confirmed => (
        l10n.bookingStatusConfirmed,
        AppColors.primary,
      ),
      BookingStatus.inProgress => (
        l10n.bookingStatusInProgress,
        AppColors.teal,
      ),
      BookingStatus.completed => (
        l10n.bookingStatusCompleted,
        context.palette.mutedText,
      ),
      BookingStatus.cancelled => (
        l10n.bookingStatusCancelled,
        AppColors.danger,
      ),
      BookingStatus.unknown => ('—', context.palette.mutedText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
