/// Lỗi nghiệp vụ auth, mang message + code từ backend để UI hiển thị.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException($code): $message';
}
