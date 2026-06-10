import 'package:go_router/go_router.dart';
import 'package:frontend/app/app_shell.dart';
import 'package:frontend/app/splash_screen.dart';
import 'package:frontend/core/router/go_router_refresh_stream.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:frontend/features/kyc/presentation/screens/kyc_screen.dart';

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.matchedLocation;
      final atSplash = location == '/splash';
      final atAuth = location == '/login' || location == '/register';

      // Chưa bootstrap xong → giữ ở splash.
      if (authState is AuthInitial) {
        return atSplash ? null : '/splash';
      }

      final isAuthenticated = authState is AuthAuthenticated;
      if (!isAuthenticated) {
        return atAuth ? null : '/login';
      }

      // Đã đăng nhập mà còn ở splash/auth → vào app.
      if (atSplash || atAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycScreen(),
      ),
    ],
  );
}
