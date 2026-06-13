/// Lỗi nghiệp vụ KYC ở tầng presentation. Datasource map DioException sang đây.
class KycException implements Exception {
  const KycException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'KycException($code): $message';
}
