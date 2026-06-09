import 'package:frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';

AuthUser authUserFromJson(Map<String, dynamic> json) {
  return AuthUser(
    id: json['id'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    roles: (json['roles'] as List<dynamic>)
        .map((role) => role as String)
        .toList(growable: false),
    kycStatus: json['kycStatus'] as String,
  );
}

AuthTokens authTokensFromJson(Map<String, dynamic> json) {
  return AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}
