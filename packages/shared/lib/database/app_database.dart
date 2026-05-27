import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedUsers extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get assignedTrainerId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedMessages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get textValue => text().named('text')();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text()();
  BoolColumn get isSystemMessage =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedCallRequests extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get trainerId => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get note => text()();
  TextColumn get status => text()();
  TextColumn get declineReason => text().nullable()();
  TextColumn get roomMetaId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedSessionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get callRequestId => text()();
  TextColumn get memberId => text()();
  TextColumn get trainerId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSec => integer().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get trainerNotes => text().nullable()();
  TextColumn get memberNotes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedRoomMetas extends Table {
  TextColumn get id => text()();
  TextColumn get callRequestId => text()();
  TextColumn get roomId => text()();
  TextColumn get trainerRoomCode => text()();
  TextColumn get memberRoomCode => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    CachedUsers,
    CachedMessages,
    CachedCallRequests,
    CachedSessionLogs,
    CachedRoomMetas,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'wtf_cache');
  }

  Stream<List<CachedMessage>> watchMessages(String chatId) {
    return (select(cachedMessages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .watch();
  }

  Stream<List<CachedSessionLog>> watchSessionLogs() {
    return (select(cachedSessionLogs)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .watch();
  }
}
