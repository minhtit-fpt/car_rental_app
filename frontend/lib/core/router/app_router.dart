import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/auth_routes.dart';
import 'package:frontend/core/router/booking_routes.dart';
import 'package:frontend/core/router/kyc_routes.dart';
import 'package:frontend/core/router/payment_routes.dart';
import 'package:frontend/core/router/owner_routes.dart';
import 'package:frontend/core/router/profile_routes.dart';
import 'package:frontend/core/router/social_routes.dart';
import 'package:frontend/core/router/vehicle_routes.dart';
import 'package:frontend/core/shell/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
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
    // Phase 11–12 routes added per phase
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
