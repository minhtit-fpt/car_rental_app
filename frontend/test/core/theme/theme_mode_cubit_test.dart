import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/storage/kv_storage.dart';
import 'package:frontend/core/theme/theme_mode_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<KvStorage> _kvWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return KvStorage(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeCubit', () {
    test('defaults to light when nothing is stored', () async {
      final cubit = ThemeModeCubit(await _kvWith({}));
      addTearDown(cubit.close);

      expect(cubit.state, ThemeMode.light);
    });

    test('reads the persisted mode on creation', () async {
      final cubit = ThemeModeCubit(await _kvWith({'theme_mode': 'dark'}));
      addTearDown(cubit.close);

      expect(cubit.state, ThemeMode.dark);
    });

    test('decodes the system mode', () async {
      final cubit = ThemeModeCubit(await _kvWith({'theme_mode': 'system'}));
      addTearDown(cubit.close);

      expect(cubit.state, ThemeMode.system);
    });

    test('falls back to light for an unknown stored value', () async {
      final cubit = ThemeModeCubit(await _kvWith({'theme_mode': 'sepia'}));
      addTearDown(cubit.close);

      expect(cubit.state, ThemeMode.light);
    });

    test('setMode emits the new mode and persists it', () async {
      final storage = await _kvWith({});
      final cubit = ThemeModeCubit(storage);
      addTearDown(cubit.close);

      await cubit.setMode(ThemeMode.dark);

      expect(cubit.state, ThemeMode.dark);
      expect(storage.themeMode, 'dark');
    });

    test('setMode persists the system mode round-trip', () async {
      final storage = await _kvWith({});
      final cubit = ThemeModeCubit(storage);
      addTearDown(cubit.close);

      await cubit.setMode(ThemeMode.system);

      expect(storage.themeMode, 'system');
      // A fresh cubit restores the persisted value.
      final restored = ThemeModeCubit(storage);
      addTearDown(restored.close);
      expect(restored.state, ThemeMode.system);
    });

    test('setMode is a no-op when the mode is unchanged', () async {
      final cubit = ThemeModeCubit(await _kvWith({'theme_mode': 'light'}));
      addTearDown(cubit.close);
      final emitted = <ThemeMode>[];
      final sub = cubit.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      await cubit.setMode(ThemeMode.light);

      expect(emitted, isEmpty);
    });
  });
}
