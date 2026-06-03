import 'package:shared_preferences/shared_preferences.dart';

/// Key-Value nhẹ cho thiết lập đơn giản (không quan hệ, không nhạy cảm).
class KvStorage {
  const KvStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboardingDone = 'onboarding_done';
  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'locale';
  static const _kLastSyncAt = 'last_sync_at';

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(_kOnboardingDone, value);

  String get themeMode => _prefs.getString(_kThemeMode) ?? 'light';
  Future<void> setThemeMode(String value) =>
      _prefs.setString(_kThemeMode, value);

  String get locale => _prefs.getString(_kLocale) ?? 'vi';
  Future<void> setLocale(String value) => _prefs.setString(_kLocale, value);

  int? get lastSyncAt => _prefs.getInt(_kLastSyncAt);
  Future<void> setLastSyncAt(int epochMs) =>
      _prefs.setInt(_kLastSyncAt, epochMs);
}
