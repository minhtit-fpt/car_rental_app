/// Lỗi nghiệp vụ Payment ở tầng presentation. Datasource map DioException sang đây.
class PaymentException implements Exception {
  const PaymentException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'PaymentException($code): $message';
}
