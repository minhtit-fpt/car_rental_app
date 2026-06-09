import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/core/network/auth_interceptor.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';

class DioClient {
  DioClient._();

  static Dio create({
    required SecureTokenStorage storage,
    required Future<void> Function() onSessionExpired,
  }) {
    final options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
    );

    // refreshDio không gắn AuthInterceptor → tránh vòng lặp khi refresh/retry.
    final refreshDio = Dio(options);
    final dio = Dio(options);
    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        refreshDio: refreshDio,
        onSessionExpired: onSessionExpired,
      ),
    );
    return dio;
  }
}
