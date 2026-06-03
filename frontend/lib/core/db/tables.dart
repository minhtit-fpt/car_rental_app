import 'package:drift/drift.dart';

/// Drift tables — local cache + offline (hướng A).
/// KHÔNG phải nguồn chân lý. id = id bản ghi trên server (mirror).
/// Mọi bảng cache có [fetchedAt] (epoch ms) để áp TTL.

// ---------- Cache đọc nhanh ----------

/// Cache danh sách xe. id = Vehicle.id server. TTL ~10 phút.
class VehiclesCache extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()(); // snapshot toàn bộ Vehicle
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cache lịch sử booking của chính user. id = Booking.id server. TTL ~30 phút.
/// ⚠️ status tiền vẫn phải hỏi server lúc thanh toán — không tin cache.
class BookingsCache extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get json => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cache thông báo. id = Notification.id server.
class NotificationsCache extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  BoolColumn get readLocal => boolean().withDefault(const Constant(false))();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Lịch sử tìm kiếm — tiện ích thuần máy (không cần lên server).
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get keyword => text()();
  TextColumn get filters => text().nullable()(); // json
  IntColumn get searchedAt => integer()();
}

// ---------- Ghi offline (outbox) ----------

/// Nháp booking — local cho tới khi submit thành công.
class BookingDrafts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vehicleId => text()(); // = Vehicle.id
  IntColumn get startTime => integer()(); // epoch ms
  IntColumn get endTime => integer()();
  BoolColumn get deliveryWanted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get syncState =>
      text().withDefault(const Constant('draft'))(); // draft|submitting

  @override
  List<String> get customConstraints =>
      ["CHECK (\"sync_state\" IN ('draft','submitting'))"];
}

/// Mirror cuộc hội thoại để hiển thị danh sách nhanh. id = ChatConversation.id.
class ChatConvLocal extends Table {
  TextColumn get id => text()();
  TextColumn get lastBody => text().nullable()();
  IntColumn get lastAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Outbox tin nhắn — gửi lúc mất mạng → hàng đợi, worker retry khi có mạng.
class ChatMessagesLocal extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()(); // null khi chưa gửi
  TextColumn get conversationId => text()();
  TextColumn get body => text()();
  TextColumn get syncState =>
      text().withDefault(const Constant('pending'))(); // pending|sent|failed

  @override
  List<String> get customConstraints =>
      ["CHECK (\"sync_state\" IN ('pending','sent','failed'))"];
}
