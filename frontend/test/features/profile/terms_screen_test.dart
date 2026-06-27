import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/locale/locale_cubit.dart';
import 'package:frontend/core/storage/kv_storage.dart';
import 'package:frontend/core/theme/theme_mode_cubit.dart';
import 'package:frontend/features/profile/presentation/screens/settings_screen.dart';
import 'package:frontend/features/profile/presentation/screens/terms_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

Widget _wrapDirect(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TermsScreen renders the localized section headings', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapDirect(const TermsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('1. Acceptance of terms'), findsOneWidget);
    expect(find.text('5. Privacy & your data'), findsOneWidget);
    expect(find.text('Last updated June 2026'), findsOneWidget);
  });

  testWidgets('Settings Terms row navigates to TermsScreen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final kv = KvStorage(prefs);

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit(kv)),
          BlocProvider<ThemeModeCubit>(create: (_) => ThemeModeCubit(kv)),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final termsRow = find.text('Terms & policies');
    expect(termsRow, findsOneWidget);
    await tester.ensureVisible(termsRow);
    await tester.pumpAndSettle();
    await tester.tap(termsRow);
    await tester.pumpAndSettle();

    // Landed on the Terms screen (a section heading only it renders).
    expect(find.text('1. Acceptance of terms'), findsOneWidget);
  });
}
