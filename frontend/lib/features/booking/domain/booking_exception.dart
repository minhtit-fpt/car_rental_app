/// Lỗi nghiệp vụ Booking ở tầng presentation. Datasource map DioException sang đây.
class BookingException implements Exception {
  const BookingException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'BookingException($code): $message';
}
