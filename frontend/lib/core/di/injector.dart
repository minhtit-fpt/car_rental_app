import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/core/db/app_database.dart';
import 'package:frontend/core/storage/kv_storage.dart';
import 'package:frontend/core/storage/secure_storage.dart';

/// Service locator toàn cục.
final GetIt sl = GetIt.instance;

/// Đăng ký 3 kho lưu trữ trên máy. Gọi 1 lần trong main() trước runApp().
Future<void> setupStorage() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerSingleton<SecureStorage>(
      const SecureStorage(FlutterSecureStorage()),
    )
    ..registerSingleton<KvStorage>(KvStorage(prefs));
}
