import 'package:equatable/equatable.dart';
import 'package:frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;

  @override
  List<Object?> get props => [user, tokens];
}
