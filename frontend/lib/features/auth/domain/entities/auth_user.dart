import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.roles,
    required this.kycStatus,
    this.email,
  });

  final String id;
  final String phone;
  final String? email;
  final List<String> roles;
  final String kycStatus;

  @override
  List<Object?> get props => [id, phone, email, roles, kycStatus];
}
