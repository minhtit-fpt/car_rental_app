import 'package:flutter/material.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Tải một [Booking] theo id rồi mở [BookingDetailScreen] — dùng khi điều
/// hướng từ thông báo, nơi chỉ có `bookingId` chứ không có [Booking] đầy đủ.
class BookingDetailLoaderScreen extends StatelessWidget {
  const BookingDetailLoaderScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Booking>(
      future: sl<BookingRepository>().getBooking(bookingId),
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
        return BookingDetailScreen(booking: snapshot.data!);
      },
    );
  }
}
