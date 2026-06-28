import 'package:frontend/features/inspection/domain/entities/damage_report.dart';
import 'package:frontend/features/inspection/domain/entities/inspection_finding.dart';

enum PhaseStatus { idle, working, done, error }

/// Trạng thái màn kiểm tra xe: tiến độ upload từng phase + kết quả VLM soi từng
/// lượt (checkinFinding/checkoutFinding) + báo cáo so sánh cuối (report).
class InspectionState {
  const InspectionState({
    this.checkin = PhaseStatus.idle,
    this.checkinCount = 0,
    this.checkinFinding,
    this.checkout = PhaseStatus.idle,
    this.checkoutCount = 0,
    this.checkoutFinding,
    this.isAnalyzing = false,
    this.report,
    this.errorMessage,
  });

  final PhaseStatus checkin;
  final int checkinCount;
  final InspectionFinding? checkinFinding;
  final PhaseStatus checkout;
  final int checkoutCount;
  final InspectionFinding? checkoutFinding;
  final bool isAnalyzing;
  final DamageReport? report;
  final String? errorMessage;

  bool get canAnalyze =>
      checkin == PhaseStatus.done &&
      checkout == PhaseStatus.done &&
      !isAnalyzing;

  InspectionState copyWith({
    PhaseStatus? checkin,
    int? checkinCount,
    InspectionFinding? checkinFinding,
    PhaseStatus? checkout,
    int? checkoutCount,
    InspectionFinding? checkoutFinding,
    bool? isAnalyzing,
    DamageReport? report,
    String? errorMessage,
  }) => InspectionState(
    checkin: checkin ?? this.checkin,
    checkinCount: checkinCount ?? this.checkinCount,
    checkinFinding: checkinFinding ?? this.checkinFinding,
    checkout: checkout ?? this.checkout,
    checkoutCount: checkoutCount ?? this.checkoutCount,
    checkoutFinding: checkoutFinding ?? this.checkoutFinding,
    isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    report: report ?? this.report,
    errorMessage: errorMessage,
  );
}
