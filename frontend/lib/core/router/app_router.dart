import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/auth_routes.dart';
import 'package:frontend/core/router/kyc_routes.dart';
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
    // Phase 3–12 routes added per phase
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
