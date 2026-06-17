import 'package:frontend/features/auth/domain/entities/auth_tokens.dart';

/// Map JSON `{ accessToken, refreshToken }` → entity [AuthTokens].
abstract final class AuthTokensModel {
  static AuthTokens fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}
