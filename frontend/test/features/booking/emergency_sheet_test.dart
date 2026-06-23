import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/utils/emergency_sheet.dart';

void main() {
  testWidgets('Emergency sheet renders national hotlines and tips', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showEmergencySheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // National emergency numbers (factual, not placeholder data).
    expect(find.text('113'), findsOneWidget);
    expect(find.text('114'), findsOneWidget);
    expect(find.text('115'), findsOneWidget);
    expect(find.text('Police'), findsOneWidget);
    expect(find.text('Safety tips'), findsOneWidget);
  });
}
