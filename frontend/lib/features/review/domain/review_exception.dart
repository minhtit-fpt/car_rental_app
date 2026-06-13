/// Lỗi nghiệp vụ Review ở tầng presentation. Datasource map DioException sang đây.
class ReviewException implements Exception {
  const ReviewException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'ReviewException($code): $message';
}
