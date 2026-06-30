/// Một tài khoản bị rule-engine cờ rủi ro (`/api/admin/risk`). `reasons` là các
/// rule đã kích hoạt — chính là lời giải thích "vì sao bị cờ" (explainable).
class AdminRiskItem {
  const AdminRiskItem({
    required this.userId,
    required this.phone,
    required this.roles,
    required this.score,
    required this.tier,
    required this.reasons,
    this.email,
  });

  final String userId;
  final String phone;
  final String? email;
  final List<String> roles;
  final int score;
  final String tier; // LOW | MEDIUM | HIGH
  final List<RiskReason> reasons;
}

class RiskReason {
  const RiskReason({required this.code, required this.label});

  final String code;
  final String label;
}
