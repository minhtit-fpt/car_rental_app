import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/router/ai_chat_routes.dart';
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
import 'package:frontend/features/map/presentation/screens/map_screen.dart';
import 'package:frontend/features/tracking/presentation/screens/live_tracking_screen.dart';
import 'package:frontend/features/tracking/presentation/screens/admin_tracking_map_screen.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_metrics_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_revenue_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_disputes_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_vehicles_cubit.dart';
import 'package:frontend/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:frontend/features/auth/domain/entities/user_role.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/screens/splash_screen.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';

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
      final isAdmin =
          authCubit.state.user?.roles.contains(UserRole.admin) ?? false;
      final home = isAdmin ? '/admin' : '/';

      // Biết kết quả rồi mà còn ở splash → điều hướng đúng đích theo role.
      if (location == _splash) {
        return loggedIn ? home : '/login';
      }

      // Chưa đăng nhập mà vào route bảo vệ → ép về login.
      if (!loggedIn && !_publicRoutes.contains(location)) {
        return '/login';
      }

      // Đã đăng nhập mà còn ở màn login/register → về trang chủ theo role.
      if (loggedIn && (location == '/login' || location == '/register')) {
        return home;
      }

      // Không phải admin thì không được vào khu vực admin.
      if (loggedIn && !isAdmin && location == '/admin') {
        return '/';
      }

      // Admin không nằm ở shell người thuê — luôn đưa về khu vực admin.
      if (loggedIn && isAdmin && location == '/') {
        return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(path: _splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VehicleListCubit>()..load(),
          child: const AppShell(),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<AdminCubit>()..loadStats()),
            BlocProvider(create: (_) => sl<AdminMetricsCubit>()..load()),
            BlocProvider(create: (_) => sl<AdminUsersCubit>()..load()),
            BlocProvider(create: (_) => sl<AdminKycCubit>()..load()),
            BlocProvider(create: (_) => sl<AdminRevenueCubit>()..load()),
            BlocProvider(create: (_) => sl<AdminDisputesCubit>()..load()),
            BlocProvider(create: (_) => sl<AdminVehiclesCubit>()..load()),
          ],
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
      GoRoute(
        path: '/tracking/:vehicleId',
        builder: (context, state) => LiveTrackingScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: '/admin/tracking',
        builder: (context, state) => const AdminTrackingMapScreen(),
      ),
      ...authRoutes,
      ...kycRoutes,
      ...vehicleRoutes,
      ...aiChatRoutes,
      ...bookingRoutes,
      ...paymentRoutes,
      ...socialRoutes,
      ...ownerRoutes,
      ...profileRoutes,
      ...adminRoutes,
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
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
