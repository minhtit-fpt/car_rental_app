import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/auth_routes.dart';
import 'package:frontend/core/router/booking_routes.dart';
import 'package:frontend/core/router/kyc_routes.dart';
import 'package:frontend/core/router/payment_routes.dart';
import 'package:frontend/core/router/admin_routes.dart';
import 'package:frontend/core/router/owner_routes.dart';
import 'package:frontend/core/router/profile_routes.dart';
import 'package:frontend/core/router/social_routes.dart';
import 'package:frontend/core/router/vehicle_routes.dart';
import 'package:frontend/core/shell/app_shell.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/screens/splash_screen.dart';

/// Các route công khai (không cần đăng nhập).
const _publicRoutes = {'/login', '/register', '/otp'};
const _splash = '/splash';

/// Tạo router có guard dựa trên [authCubit]. Router re-evaluate `redirect`
/// mỗi khi trạng thái phiên đổi (qua [refreshListenable]).
GoRouter createAppRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: _splash,
    refreshListenable: _GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final location = state.matchedLocation;

      // Đang khôi phục phiên → giữ ở splash.
      if (status == AuthStatus.unknown) {
        return location == _splash ? null : _splash;
      }

      final loggedIn = status == AuthStatus.authenticated;

      // Biết kết quả rồi mà còn ở splash → điều hướng đúng đích.
      if (location == _splash) {
        return loggedIn ? '/' : '/login';
      }

      // Chưa đăng nhập mà vào route bảo vệ → ép về login.
      if (!loggedIn && !_publicRoutes.contains(location)) {
        return '/login';
      }

      // Đã đăng nhập mà còn ở màn login/register → về trang chủ.
      if (loggedIn &&
          (location == '/login' || location == '/register')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: _splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
      ),
      ...authRoutes,
      ...kycRoutes,
      ...vehicleRoutes,
      ...bookingRoutes,
      ...paymentRoutes,
      ...socialRoutes,
      ...ownerRoutes,
      ...profileRoutes,
      ...adminRoutes,
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}

/// Cầu nối `Stream<AuthState>` → `Listenable` cho GoRouter.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
