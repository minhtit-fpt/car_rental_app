import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/storage/kv_storage.dart';

/// Quản lý chế độ giao diện (system / light / dark).
///
/// Đọc giá trị ban đầu từ [KvStorage] (mặc định `light`) và persist mỗi lần đổi
/// để giữ nguyên sau khi mở lại app. [MaterialApp] đọc `themeMode` từ state này
/// và rebuild khi đổi — giống cơ chế của LocaleCubit.
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._storage) : super(_decode(_storage.themeMode));

  final KvStorage _storage;

  /// Đổi chế độ runtime + persist. Bỏ qua nếu trùng chế độ hiện tại.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    await _storage.setThemeMode(_encode(mode));
    emit(mode);
  }

  /// Chuỗi lưu trữ → [ThemeMode]; fallback `light` cho giá trị lạ.
  static ThemeMode _decode(String value) => switch (value) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
  };
}
