import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupStorage(); // Drift + SecureStorage + KvStorage (GetIt)
  setupAuth(); // ApiClient + auth repository/usecases + AuthCubit
  setupAdmin(); // admin repository + AdminCubit factory
  setupVehicle(); // vehicle repository + VehicleListCubit factory
  setupBooking(); // booking repository + BookingCubit factory
  setupPayment(); // payment repository + PaymentCubit factory
  setupReview(); // review repository + ReviewCubit factory
  setupKyc(); // kyc repository + KycStatusCubit factory
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Khôi phục phiên từ token đã lưu (fire-and-forget — router hiện splash chờ).
  final authCubit = sl<AuthCubit>();
  unawaited(authCubit.checkSession());

  runApp(RideVNApp(authCubit: authCubit));
}

class RideVNApp extends StatefulWidget {
  const RideVNApp({super.key, required this.authCubit});

  final AuthCubit authCubit;

  @override
  State<RideVNApp> createState() => _RideVNAppState();
}

class _RideVNAppState extends State<RideVNApp> {
  late final GoRouter _router = createAppRouter(widget.authCubit);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: widget.authCubit,
      child: MaterialApp.router(
        title: 'RideVN',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(context),
        routerConfig: _router,
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final base = GoogleFonts.beVietnamProTextTheme(Theme.of(context).textTheme);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.placeholderText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
