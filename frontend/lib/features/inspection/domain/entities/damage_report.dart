/// Mức độ hư hỏng do VLM đánh giá.
enum DamageSeverity { minor, moderate, severe }

/// Một hạng mục hư hỏng được AI phát hiện khi so ảnh nhận/trả xe.
class DamageItem {
  const DamageItem({
    required this.label,
    required this.severity,
    required this.description,
  });

  final String label;
  final DamageSeverity severity;
  final String description;
}

/// Báo cáo hư hỏng cho một đơn đặt: tóm tắt, danh sách hư hỏng mới, gợi ý bồi
/// thường (VND) và ảnh hai mốc nhận/trả để đối chiếu.
class DamageReport {
  const DamageReport({
    required this.summary,
    required this.items,
    required this.estimatedCost,
    required this.createdAt,
    required this.beforePhotos,
    required this.afterPhotos,
  });

  final String summary;
  final List<DamageItem> items;
  final int estimatedCost;
  final DateTime createdAt;
  final List<String> beforePhotos;
  final List<String> afterPhotos;

  bool get hasDamage => items.isNotEmpty;
}
