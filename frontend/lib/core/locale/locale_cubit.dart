import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/storage/kv_storage.dart';

/// Quản lý ngôn ngữ hiện tại của app.
///
/// Đọc giá trị ban đầu từ [KvStorage] (mặc định `vi`) và persist mỗi lần đổi
/// để giữ nguyên sau khi mở lại app. [MaterialApp] rebuild theo state này.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(_resolve(_storage.locale));

  final KvStorage _storage;

  /// Các ngôn ngữ app hỗ trợ — phải khớp `supportedLocales` của MaterialApp.
  static const supportedLocales = <Locale>[Locale('vi'), Locale('en')];

  /// Đổi ngôn ngữ runtime + persist. Bỏ qua nếu trùng ngôn ngữ hiện tại.
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == state.languageCode) return;
    await _storage.setLocale(locale.languageCode);
    emit(locale);
  }

  /// Ép giá trị lưu trữ về 1 trong [supportedLocales]; fallback `vi`.
  static Locale _resolve(String code) => supportedLocales.firstWhere(
    (l) => l.languageCode == code,
    orElse: () => const Locale('vi'),
  );
}
