/// Lưu ngữ cảnh tìm kiếm gần nhất ở màn chính (khoảng ngày nhận/trả) để các màn
/// khác — đặc biệt là luồng đặt xe — prefill theo.
///
/// App-scoped singleton (đăng ký trong DI), không lưu xuống đĩa: chỉ giữ trong
/// phiên chạy hiện tại.
class SearchSession {
  DateTime? startDate;
  DateTime? endDate;

  bool get hasDates => startDate != null && endDate != null;

  void setDates(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
  }
}
