import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/booking/data/models/booking_mapper.dart';
import 'package:frontend/features/booking/domain/booking_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

class BookingRemoteDataSource {
  const BookingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Booking> create(CreateBookingParams params) async {
    try {
      final res = await _dio.post<dynamic>(
        BookingEndpoints.list,
        data: {
          'vehicleId': params.vehicleId,
          'startTime': params.startTime.toUtc().toIso8601String(),
          'endTime': params.endTime.toUtc().toIso8601String(),
          'deliveryRequested': params.deliveryRequested,
        },
      );
      return bookingFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Booking>> getMyBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        BookingEndpoints.list,
        queryParameters: {
          if (status != null) 'status': _statusWire(status),
          'page': page,
          'limit': limit,
        },
      );
      final data = _data(res) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => bookingFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Booking> cancel(String id) async {
    try {
      final res = await _dio.post<dynamic>(BookingEndpoints.cancel(id));
      return bookingFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  dynamic _data(Response<dynamic> res) {
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }

  String _statusWire(BookingStatus status) => switch (status) {
        BookingStatus.pendingPayment => 'PENDING_PAYMENT',
        BookingStatus.confirmed => 'CONFIRMED',
        BookingStatus.inProgress => 'IN_PROGRESS',
        BookingStatus.completed => 'COMPLETED',
        BookingStatus.cancelled => 'CANCELLED',
      };

  BookingException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return BookingException(
        (data['error'] as String?) ?? 'Đã xảy ra lỗi',
        code: data['code'] as String?,
      );
    }
    return const BookingException('Không thể kết nối tới máy chủ');
  }
}
