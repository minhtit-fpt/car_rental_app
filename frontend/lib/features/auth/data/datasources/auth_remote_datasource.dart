import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/auth/*`. Trả JSON thô (Map), việc map sang entity
/// để repository đảm nhiệm.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  /// → `{ user, tokens }`
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final data = await _client.post(
      '/api/auth/login',
      data: {'phone': phone, 'password': password},
    );
    return data as Map<String, dynamic>;
  }

  /// → `{ user, tokens }`
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    final data = await _client.post(
      '/api/auth/register',
      data: {
        'phone': phone,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
    return data as Map<String, dynamic>;
  }

  /// → `PublicUser`
  Future<Map<String, dynamic>> me() async {
    final data = await _client.get('/api/auth/me');
    return data as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) =>
      _client.post('/api/auth/logout', data: {'refreshToken': refreshToken});
}
