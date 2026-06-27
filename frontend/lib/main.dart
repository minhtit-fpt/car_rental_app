import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/locale/locale_cubit.dart';
import 'package:frontend/core/notifications/local_notification_service.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_mode_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

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
  setupOwner(); // owner repository + owner/bookings/revenue cubits
  setupNotification(); // notification repository + NotificationCubit factory
  setupLoyalty(); // loyalty repository + LoyaltyCubit factory
  setupCommunity(); // community repository + CommunityCubit factory
  setupChat(); // chat repository + conversation/chat cubits
  setupFavorite(); // favorite repository + FavoriteCubit singleton
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

class _RideVNAppState extends State<RideVNApp> with WidgetsBindingObserver {
  late final GoRouter _router = createAppRouter(widget.authCubit);
  final FavoriteCubit _favoriteCubit = sl<FavoriteCubit>();
  final LocaleCubit _localeCubit = sl<LocaleCubit>();
  final ThemeModeCubit _themeModeCubit = sl<ThemeModeCubit>();
  final NotificationCubit _notificationCubit = sl<NotificationCubit>();
  final LocalNotificationService _localNotifications =
      sl<LocalNotificationService>();

  bool get _isAuthenticated =>
      widget.authCubit.state.status == AuthStatus.authenticated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo popup khay OS; chạm popup → điều hướng theo route trong payload.
    unawaited(
      _localNotifications.init(
        onTap: (payload) {
          if (payload != null && payload.isNotEmpty) _router.push(payload);
        },
      ),
    );
    // Phiên khôi phục sẵn (token còn hạn) → nạp ngay + bật polling thông báo.
    if (_isAuthenticated) {
      _favoriteCubit.load();
      _startNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Tạm dừng polling khi app vào nền, chạy lại khi quay về (chỉ khi đã đăng nhập).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isAuthenticated) return;
    if (state == AppLifecycleState.resumed) {
      _notificationCubit.startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _notificationCubit.stopAutoRefresh();
    }
  }

  Future<void> _startNotifications() async {
    await _localNotifications.requestPermissions();
    _notificationCubit.startAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: widget.authCubit),
        BlocProvider<FavoriteCubit>.value(value: _favoriteCubit),
        BlocProvider<NotificationCubit>.value(value: _notificationCubit),
        BlocProvider<LocaleCubit>.value(value: _localeCubit),
        BlocProvider<ThemeModeCubit>.value(value: _themeModeCubit),
      ],
      // Đồng bộ theo phiên: đăng nhập → nạp + bật polling thông báo; đăng xuất → xoá.
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:
              _favoriteCubit.load();
              unawaited(_startNotifications());
            case AuthStatus.unauthenticated:
              _favoriteCubit.clear();
              _notificationCubit.reset();
            case AuthStatus.unknown:
            case AuthStatus.authenticating:
              break;
          }
        },
        child: BlocBuilder<LocaleCubit, Locale>(
          bloc: _localeCubit,
          builder: (context, locale) => BlocBuilder<ThemeModeCubit, ThemeMode>(
            bloc: _themeModeCubit,
            builder: (context, themeMode) => MaterialApp.router(
              title: 'RideVN',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}
