import 'package:frontend/features/inspection/domain/entities/damage_report.dart';

enum PhaseStatus { idle, working, done, error }

/// Trạng thái màn kiểm tra xe: tiến độ upload từng phase + báo cáo hư hỏng.
class InspectionState {
  const InspectionState({
    this.checkin = PhaseStatus.idle,
    this.checkinCount = 0,
    this.checkout = PhaseStatus.idle,
    this.checkoutCount = 0,
    this.isAnalyzing = false,
    this.report,
    this.errorMessage,
  });

  final PhaseStatus checkin;
  final int checkinCount;
  final PhaseStatus checkout;
  final int checkoutCount;
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
    PhaseStatus? checkout,
    int? checkoutCount,
    bool? isAnalyzing,
    DamageReport? report,
    String? errorMessage,
  }) => InspectionState(
    checkin: checkin ?? this.checkin,
    checkinCount: checkinCount ?? this.checkinCount,
    checkout: checkout ?? this.checkout,
    checkoutCount: checkoutCount ?? this.checkoutCount,
    isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    report: report ?? this.report,
    errorMessage: errorMessage,
  );
}
