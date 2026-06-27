import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor chỉ dùng cho debug: in request / response / lỗi ra console để
/// chẩn đoán nhanh sự cố kết nối backend (sai base URL, cleartext bị chặn,
/// server trả lỗi, v.v.).
///
/// Chỉ nên đăng ký khi [kDebugMode] — không chạy ở bản release để tránh lộ
/// thông tin và tốn hiệu năng.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] → ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] ✖ ${err.type.name} → ${err.requestOptions.uri}');
    debugPrint(
      '[API]   status=${err.response?.statusCode} message=${err.message}',
    );
    // `err.error` chứa nguyên nhân gốc (SocketException: Connection refused,
    // ClientException, HandshakeException...) — đầu mối quan trọng nhất khi
    // request không tới được server.
    if (err.error != null) {
      debugPrint('[API]   cause=${err.error}');
    }
    if (err.response?.data != null) {
      debugPrint('[API]   body=${err.response?.data}');
    }
    handler.next(err);
  }
}
