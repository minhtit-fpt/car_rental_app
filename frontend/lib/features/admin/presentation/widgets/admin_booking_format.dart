import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Nhãn + màu cho trạng thái đơn / thanh toán, dùng chung cho list + detail.

String bookingStatusLabel(String status) => switch (status) {
  'PENDING_PAYMENT' => 'Chờ thanh toán',
  'CONFIRMED' => 'Đã xác nhận',
  'IN_PROGRESS' => 'Đang thuê',
  'COMPLETED' => 'Hoàn tất',
  'CANCELLED' => 'Đã huỷ',
  _ => status,
};

Color bookingStatusColor(String status) => switch (status) {
  'PENDING_PAYMENT' => AppColors.warning,
  'CONFIRMED' => AppColors.adminBlue,
  'IN_PROGRESS' => AppColors.adminTeal,
  'COMPLETED' => AppColors.success,
  'CANCELLED' => AppColors.danger,
  _ => AppColors.adminMuted,
};

String paymentStatusLabel(String status) => switch (status) {
  'PENDING' => 'Chờ thanh toán',
  'PAID' => 'Đã thanh toán',
  'FAILED' => 'Thất bại',
  'REFUNDED' => 'Đã hoàn tiền',
  _ => status,
};

Color paymentStatusColor(String status) => switch (status) {
  'PAID' => AppColors.success,
  'REFUNDED' => AppColors.adminTeal,
  'FAILED' => AppColors.danger,
  _ => AppColors.warning,
};

/// Định dạng tiền VND đơn giản: nhóm 3 chữ số bằng dấu chấm + hậu tố đ.
String formatVnd(num amount) {
  final digits = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '$bufđ';
}
