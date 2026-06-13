// Validation phía client — backend vẫn validate lại bằng Zod.

String? validatePhone(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return 'Vui lòng nhập số điện thoại';
  final digits = raw.replaceAll(RegExp(r'[\s.\-()]'), '');
  if (!RegExp(r'^(0|\+?84)\d{9}$').hasMatch(digits)) {
    return 'Số điện thoại không hợp lệ';
  }
  return null;
}

String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
  if (v.length < 8) return 'Mật khẩu phải tối thiểu 8 ký tự';
  return null;
}

String? validateOptionalEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
    return 'Email không hợp lệ';
  }
  return null;
}
