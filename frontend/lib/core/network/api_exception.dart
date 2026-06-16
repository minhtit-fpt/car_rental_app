/// Lỗi đã được chuẩn hóa từ envelope `{ success:false, error, code }` của backend.
/// Tầng presentation chỉ cần đọc [message] để hiển thị cho người dùng.
class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => 'ApiException(code: $code, status: $statusCode): $message';
}
