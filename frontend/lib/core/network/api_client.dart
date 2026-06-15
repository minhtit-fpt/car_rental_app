import 'package:dio/dio.dart';

import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/storage/secure_storage.dart';

/// Bọc Dio: gắn access token, tự refresh khi gặp 401, và bóc envelope
/// `{ success, data }` / `{ success, error, code }` của backend.
///
/// Trả về thẳng phần `data` của envelope; ném [ApiException] khi thất bại.
class ApiClient {
  ApiClient(this._secureStorage, {Dio? dio, Dio? refreshDio})
      : _dio = dio ?? Dio(_baseOptions),
        _refreshDio = refreshDio ?? Dio(_baseOptions) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  final SecureStorage _secureStorage;
  final Dio _dio;

  /// Dio riêng cho refresh — KHÔNG gắn interceptor để tránh đệ quy 401.
  final Dio _refreshDio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: _normalizeBaseUrl(AppConfig.apiBaseUrl),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
  );

  /// Chuẩn hoá base URL về dạng origin (không `/` cuối, không `/api` cuối) vì
  /// mọi path đã tự kèm `/api/...`. Tránh lỗi nhân đôi `/api/api/...`.
  static String _normalizeBaseUrl(String raw) {
    var url = raw.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.endsWith('/api')) {
      url = url.substring(0, url.length - '/api'.length);
    }
    return url;
  }

  /// Các endpoint auth không được kích hoạt refresh (tự chúng cấp/huỷ token).
  static const Set<String> _noRefreshPaths = {
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/auth/logout',
  };

  Future<dynamic> post(String path, {Object? data}) =>
      _send(() => _dio.post<dynamic>(path, data: data));

  Future<dynamic> get(String path) => _send(() => _dio.get<dynamic>(path));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      final res = await call();
      final body = res.data;
      if (body is Map && body['success'] == true) {
        return body['data'];
      }
      throw ApiException(
        (body is Map ? body['error'] as String? : null) ??
            'Phản hồi không hợp lệ từ máy chủ',
        code: body is Map ? body['code'] as String? : null,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return ApiException(
        data['error'] as String,
        code: data['code'] as String?,
        statusCode: e.response?.statusCode,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.',
        code: 'NETWORK_ERROR',
      );
    }
    return ApiException(
      e.message ?? 'Đã xảy ra lỗi không xác định',
      statusCode: e.response?.statusCode,
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized || _noRefreshPaths.contains(path) || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await _tryRefresh();
    if (!refreshed) {
      await _secureStorage.clear();
      return handler.next(err);
    }

    final newToken = await _secureStorage.readAccessToken();
    final retryOptions = err.requestOptions
      ..extra['retried'] = true
      ..headers['Authorization'] = 'Bearer $newToken';
    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final res = await _refreshDio.post<dynamic>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = res.data;
      if (body is Map && body['success'] == true) {
        final tokens = body['data']['tokens'] as Map<String, dynamic>;
        await _secureStorage.saveTokens(
          accessToken: tokens['accessToken'] as String,
          refreshToken: tokens['refreshToken'] as String,
        );
        return true;
      }
      return false;
    } on DioException {
      return false;
    }
  }
}
