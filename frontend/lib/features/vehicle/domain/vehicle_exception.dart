/// Lỗi nghiệp vụ Vehicle ở tầng presentation. Datasource map DioException sang đây.
class VehicleException implements Exception {
  const VehicleException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'VehicleException($code): $message';
}
