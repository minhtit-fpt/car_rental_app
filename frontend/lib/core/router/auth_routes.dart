import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:frontend/features/auth/presentation/screens/otp_verification_screen.dart';

final authRoutes = [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(
    path: '/register',
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: '/otp',
    builder: (context, state) {
      final phone = state.extra as String? ?? '';
      return OtpVerificationScreen(phone: phone);
    },
  ),
];
