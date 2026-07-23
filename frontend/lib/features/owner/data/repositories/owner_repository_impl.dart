import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/data/datasources/owner_remote_datasource.dart';
import 'package:frontend/features/owner/data/models/owner_booking_model.dart';
import 'package:frontend/features/owner/data/models/owner_revenue_model.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  const OwnerRepositoryImpl(this._remote);

  final OwnerRemoteDataSource _remote;

  @override
  Future<List<OwnerBooking>> listBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final items = await _remote.listBookings(
      status: _statusToApi(status),
      page: page,
      limit: limit,
    );
    return items
        .map((e) => OwnerBookingModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<OwnerBooking> getBookingById(String id) async =>
      OwnerBookingModel.fromJson(await _remote.getBookingById(id));

  @override
  Future<OwnerBooking> approve(String id) async =>
      OwnerBookingModel.fromJson(await _remote.approve(id));

  @override
  Future<OwnerBooking> reject(String id) async =>
      OwnerBookingModel.fromJson(await _remote.reject(id));

  @override
  Future<OwnerRevenue> getRevenue({int months = 6}) async =>
      OwnerRevenueModel.fromJson(await _remote.revenue(months: months));

  static String? _statusToApi(BookingStatus? status) => switch (status) {
    null || BookingStatus.unknown => null,
    BookingStatus.pendingPayment => 'PENDING_PAYMENT',
    BookingStatus.awaitingOwner => 'AWAITING_OWNER',
    BookingStatus.confirmed => 'CONFIRMED',
    BookingStatus.inProgress => 'IN_PROGRESS',
    BookingStatus.completed => 'COMPLETED',
    BookingStatus.cancelled => 'CANCELLED',
  };
}
