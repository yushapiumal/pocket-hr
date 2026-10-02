import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Punches extends Table {
  TextColumn get attendanceId => text()();
  TextColumn get uid => text()();
  TextColumn get type => text()(); // checkin / checkout
  TextColumn get time => text()(); // ISO string
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get address => text()();

  TextColumn get deviceId => text().withDefault(const Constant(''))();
  TextColumn get deviceModel => text().withDefault(const Constant(''))();
  TextColumn get deviceBrand => text().withDefault(const Constant(''))();
  TextColumn get devicePlatform => text().withDefault(const Constant(''))();
  TextColumn get deviceVersion => text().withDefault(const Constant(''))();
  TextColumn get deviceIdentifier => text().withDefault(const Constant(''))();
  TextColumn get deviceIp => text().withDefault(const Constant(''))();
  IntColumn get batteryLevel => integer().withDefault(const Constant(0))();

  TextColumn get tenant => text().withDefault(const Constant(''))();
  IntColumn get isRemote => integer().withDefault(const Constant(0))();
  IntColumn get isSynced => integer().withDefault(const Constant(0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncAttempt => text().nullable()();

  @override
  Set<Column> get primaryKey => {attendanceId};
}

@DriftDatabase(tables: [Punches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pocket_hr_attendance_db');
  }
}
