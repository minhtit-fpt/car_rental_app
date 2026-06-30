/// Kết quả trợ lý AI cho một tranh chấp (Phase 4). Advisory: fact cứng + mức
/// hoàn tiền NEO (tính ở BE, không do LLM sinh) + phần AI tuỳ chọn (null khi
/// LM Studio offline).
class DisputeAnalysis {
  const DisputeAnalysis({
    required this.facts,
    required this.anchoredRefund,
    this.ai,
    this.aiError,
  });

  final DisputeFacts facts;
  final double anchoredRefund;
  final DisputeAi? ai;
  final String? aiError;
}

/// Dữ liệu cứng đã được BE xác minh.
class DisputeFacts {
  const DisputeFacts({
    required this.raisedByRole,
    required this.bookingStatus,
    required this.vehicleTitle,
    required this.paymentStatus,
    required this.paidAmount,
    required this.contractSigned,
    required this.hasCheckin,
    required this.hasCheckout,
    required this.damageSummary,
    required this.estimatedCost,
    required this.messageCount,
  });

  final String raisedByRole; // renter | owner | other
  final String bookingStatus;
  final String vehicleTitle;
  final String? paymentStatus;
  final double? paidAmount;
  final bool contractSigned;
  final bool hasCheckin;
  final bool hasCheckout;
  final String? damageSummary;
  final int estimatedCost;
  final int messageCount;
}

/// Phần suy luận của LLM (advisory).
class DisputeAi {
  const DisputeAi({
    required this.summary,
    required this.timeline,
    required this.faultParty,
    required this.confidence,
    required this.recommendation,
  });

  final String summary;
  final List<String> timeline;
  final String faultParty; // renter | owner | shared | unclear
  final String confidence; // low | medium | high
  final String recommendation;
}
