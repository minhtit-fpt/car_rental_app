import 'package:flutter/material.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';
import 'package:frontend/features/owner/presentation/screens/booking_request_detail_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Tải một [OwnerBooking] theo id rồi mở [BookingRequestDetailScreen] — dùng
/// khi điều hướng từ thông báo, nơi chỉ có `bookingId` chứ không có
/// [OwnerBooking] đầy đủ qua `extra`.
class BookingRequestDetailLoaderScreen extends StatelessWidget {
  const BookingRequestDetailLoaderScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OwnerBooking>(
      future: sl<OwnerRepository>().getBookingById(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: context.palette.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            backgroundColor: context.palette.background,
            appBar: AppBar(backgroundColor: context.palette.surface),
            body: Center(child: Text(l10n.commonError)),
          );
        }
        return BookingRequestDetailScreen(booking: snapshot.data!);
      },
    );
  }
}
