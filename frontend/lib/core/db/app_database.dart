import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:frontend/core/db/tables.dart';

part 'app_database.g.dart';

/// SQLite cục bộ (Drift) — cache + offline theo hướng A.
/// SQLCipher: TẮT (quyết định đã chốt). Token KHÔNG để ở đây — dùng SecureStorage.
@DriftDatabase(
  tables: [
    VehiclesCache,
    BookingsCache,
    NotificationsCache,
    SearchHistory,
    BookingDrafts,
    ChatConvLocal,
    ChatMessagesLocal,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ridevn.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
