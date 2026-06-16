import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/entities/user_role.dart';

/// Map JSON `PublicUser` từ backend → entity [AuthUser].
abstract final class AuthUserModel {
  static AuthUser fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        roles: (json['roles'] as List<dynamic>)
            .map((e) => UserRole.fromApi(e as String))
            .toList(growable: false),
        kycStatus: json['kycStatus'] as String,
      );
}
