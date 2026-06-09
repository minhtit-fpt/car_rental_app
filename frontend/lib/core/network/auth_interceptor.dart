import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';

/// Gắn Bearer access token vào request và tự refresh khi gặp 401.
/// Refresh dùng [refreshDio] riêng (không gắn interceptor này) để tránh đệ quy.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.refreshDio,
    required this.onSessionExpired,
  });

  final SecureTokenStorage storage;
  final Dio refreshDio;
  final Future<void> Function() onSessionExpired;

  // Single-flight: nhiều 401 đồng thời chỉ refresh một lần.
  Future<String?>? _refreshFuture;

  static const _skipAuthPaths = <String>{
    AuthEndpoints.login,
    AuthEndpoints.register,
    AuthEndpoints.refresh,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_skipAuthPaths.contains(options.path)) {
      final token = await storage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;
    final isSkip = _skipAuthPaths.contains(err.requestOptions.path);

    if (!isUnauthorized || alreadyRetried || isSkip) {
      return handler.next(err);
    }

    final newToken = await _refreshAccessToken();
    if (newToken == null) {
      await storage.clear();
      await onSessionExpired();
      return handler.next(err);
    }

    try {
      final options = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['__retried'] = true;
      final retried = await refreshDio.fetch<dynamic>(options);
      return handler.resolve(retried);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final res = await refreshDio.post<dynamic>(
        AuthEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final body = res.data as Map<String, dynamic>;
      final tokens = (body['data'] as Map<String, dynamic>)['tokens']
          as Map<String, dynamic>;
      final accessToken = tokens['accessToken'] as String;
      final newRefreshToken = tokens['refreshToken'] as String;
      await storage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return accessToken;
    } on DioException {
      return null;
    }
  }
}
