import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/storage/secure_storage.dart';

/// Gọi AI service (FastAPI) — origin RIÊNG với backend, trả `text/plain`
/// streaming nên KHÔNG dùng [ApiClient] (vốn bóc envelope `{success,data}`).
///
/// Tự gắn `Authorization: Bearer <token>` để service forward sang backend cho
/// tool `get_my_bookings` (userId suy từ token, không do LLM bịa).
class AiChatRemoteDataSource {
  AiChatRemoteDataSource(this._secureStorage, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _normalize(AppConfig.aiBaseUrl),
              connectTimeout: const Duration(seconds: 10),
              // LLM local sinh chậm → không đặt receiveTimeout ngắn.
              receiveTimeout: const Duration(minutes: 3),
            ),
          );

  final SecureStorage _secureStorage;
  final Dio _dio;

  static String _normalize(String raw) {
    var url = raw.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// `POST /chat` với `stream=true` → trả luồng delta văn bản (đã giải mã UTF-8
  /// an toàn qua ranh giới chunk để không vỡ ký tự tiếng Việt).
  Stream<String> streamReply({
    required String message,
    required List<Map<String, String>> history,
  }) async* {
    final token = await _secureStorage.readAccessToken();
    try {
      final response = await _dio.post<ResponseBody>(
        '/chat',
        data: {'message': message, 'history': history, 'stream': true},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      final body = response.data;
      if (body == null) {
        throw const ApiException('Trợ lý AI không phản hồi.');
      }
      yield* body.stream
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 503) {
      return const ApiException(
        'Trợ lý AI đang khởi động (model chưa sẵn sàng). Vui lòng thử lại sau.',
        code: 'AI_NOT_READY',
        statusCode: 503,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Không kết nối được trợ lý AI. Kiểm tra service đang chạy chưa.',
        code: 'AI_UNREACHABLE',
      );
    }
    return ApiException(
      e.message ?? 'Lỗi không xác định khi gọi trợ lý AI.',
      statusCode: status,
    );
  }
}
