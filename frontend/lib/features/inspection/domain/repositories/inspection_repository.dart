import 'package:frontend/features/inspection/domain/entities/damage_report.dart';

/// Hợp đồng cho luồng kiểm tra xe (check-in/check-out) + báo cáo hư hỏng AI.
abstract interface class InspectionRepository {
  /// Upload 1 ảnh kiểm tra, trả về `objectKey` (presign + PUT).
  /// [phase] ∈ {CHECKIN, CHECKOUT}; [contentType] ∈ {image/jpeg, image/png}.
  Future<String> uploadPhoto({
    required String bookingId,
    required String phase,
    required List<int> bytes,
    required String contentType,
  });

  /// Lưu bộ ảnh đã upload cho một phase.
  Future<void> submitInspection({
    required String bookingId,
    required String phase,
    required List<String> photoKeys,
  });

  /// Chạy VLM so ảnh nhận/trả xe → báo cáo hư hỏng.
  Future<DamageReport> analyzeDamage(String bookingId);

  /// Lấy báo cáo hư hỏng đã lưu (nếu có).
  Future<DamageReport> getDamageReport(String bookingId);
}
