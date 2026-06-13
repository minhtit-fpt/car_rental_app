import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/auth/data/models/auth_mappers.dart';
import 'package:frontend/features/auth/domain/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSession> register({
    required String phone,
    required String password,
    String? email,
  }) {
    return _session(
      () => _dio.post<dynamic>(
        AuthEndpoints.register,
        data: {
          'phone': phone,
          'password': password,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      ),
    );
  }

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) {
    return _session(
      () => _dio.post<dynamic>(
        AuthEndpoints.login,
        data: {'phone': phone, 'password': password},
      ),
    );
  }

  Future<AuthUser> getCurrentUser() async {
    try {
      final res = await _dio.get<dynamic>(AuthEndpoints.me);
      return authUserFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthUser> updateProfile({String? email}) async {
    try {
      final res = await _dio.patch<dynamic>(
        UserEndpoints.me,
        data: {'email': email},
      );
      return authUserFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<dynamic>(
        AuthEndpoints.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthSession> _session(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final res = await request();
      final data = _data(res) as Map<String, dynamic>;
      return AuthSession(
        user: authUserFromJson(data['user'] as Map<String, dynamic>),
        tokens: authTokensFromJson(data['tokens'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  dynamic _data(Response<dynamic> res) {
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }

  AuthException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return AuthException(
        (data['error'] as String?) ?? 'Đã xảy ra lỗi',
        code: data['code'] as String?,
      );
    }
    return const AuthException('Không thể kết nối tới máy chủ');
  }
}
