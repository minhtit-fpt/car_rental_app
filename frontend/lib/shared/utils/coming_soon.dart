import 'package:flutter/material.dart';

/// Hiển thị SnackBar "`feature` sắp có" cho các điểm chạm chưa nối
/// backend / feature khác. Dùng thay cho `onTap: () {}` rỗng câm để người dùng
/// luôn nhận phản hồi rõ ràng.
void showComingSoonSnack(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$feature sắp có'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
