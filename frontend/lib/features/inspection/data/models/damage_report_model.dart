import 'package:frontend/features/inspection/domain/entities/damage_report.dart';

/// Map JSON từ `GET/POST /api/bookings/:id/damage-report` → [DamageReport].
class DamageReportModel {
  const DamageReportModel._();

  static DamageReport fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    return DamageReport(
      summary: json['summary'] as String? ?? '',
      estimatedCost: (json['estimatedCost'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      beforePhotos: _stringList(json['beforePhotos']),
      afterPhotos: _stringList(json['afterPhotos']),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(_itemFromJson)
          .toList(),
    );
  }

  static DamageItem _itemFromJson(Map<String, dynamic> json) => DamageItem(
    label: json['label'] as String? ?? '',
    description: json['description'] as String? ?? '',
    severity: _severityOf(json['severity'] as String?),
  );

  static DamageSeverity _severityOf(String? raw) => switch (raw) {
    'severe' => DamageSeverity.severe,
    'moderate' => DamageSeverity.moderate,
    _ => DamageSeverity.minor,
  };

  static List<String> _stringList(dynamic raw) =>
      (raw as List<dynamic>? ?? const []).whereType<String>().toList();
}
