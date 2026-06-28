/// Kết quả VLM soi 1 lượt kiểm tra (nhận/trả) — tình trạng hư hỏng tại thời điểm
/// đó. null (ở tầng repo) nghĩa là AI chưa chạy được (VLM lỗi/tắt).
class InspectionFinding {
  const InspectionFinding({required this.summary, required this.damageCount});

  final String summary;
  final int damageCount;

  bool get hasDamage => damageCount > 0;
}
