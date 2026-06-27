import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/utils/price_format.dart';

/// Tiện ích chia sẻ — bọc `share_plus` để phần còn lại của app không phụ thuộc
/// trực tiếp vào plugin. Payload được tách thành hàm thuần [buildVehicleShareText]
/// để unit test không cần plugin/native.

/// Deep-link tới chi tiết một xe (khớp route `/vehicles/:id`).
String vehicleShareLink(String vehicleId) =>
    '${AppConfig.webBaseUrl}/vehicles/$vehicleId';

/// Nội dung text chia sẻ cho một [vehicle], đã localize qua [l10n].
/// Gồm: tên xe + giá/ngày (đã format) + deep-link.
String buildVehicleShareText(AppLocalizations l10n, Vehicle vehicle) {
  return l10n.vehicleShareMessage(
    vehicle.name,
    formatPricePerDayK(vehicle.pricePerDay),
    vehicleShareLink(vehicle.id),
  );
}

/// Mở sheet chia sẻ hệ thống với payload đã localize cho [vehicle].
Future<void> shareVehicle(BuildContext context, Vehicle vehicle) {
  final text = buildVehicleShareText(AppLocalizations.of(context), vehicle);
  return SharePlus.instance.share(
    ShareParams(text: text, subject: vehicle.name),
  );
}
