import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/locale/locale_cubit.dart';
import 'package:frontend/core/storage/kv_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<KvStorage> _kvWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return KvStorage(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit', () {
    test('defaults to vi when nothing is stored', () async {
      final cubit = LocaleCubit(await _kvWith({}));
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('vi'));
    });

    test('reads the persisted locale on creation', () async {
      final cubit = LocaleCubit(await _kvWith({'locale': 'en'}));
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('en'));
    });

    test('falls back to vi for an unsupported stored code', () async {
      final cubit = LocaleCubit(await _kvWith({'locale': 'zz'}));
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('vi'));
    });

    test('setLocale emits the new locale and persists it', () async {
      final storage = await _kvWith({});
      final cubit = LocaleCubit(storage);
      addTearDown(cubit.close);

      await cubit.setLocale(const Locale('en'));

      expect(cubit.state, const Locale('en'));
      expect(storage.locale, 'en');
    });

    test('setLocale is a no-op when the locale is unchanged', () async {
      final cubit = LocaleCubit(await _kvWith({'locale': 'vi'}));
      addTearDown(cubit.close);
      final emitted = <Locale>[];
      final sub = cubit.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      await cubit.setLocale(const Locale('vi'));

      expect(emitted, isEmpty);
    });
  });
}
