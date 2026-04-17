import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cn_pocket_hr/models/hr/check_in_check_out_model.dart';
import 'package:cn_pocket_hr/api/api_service.dart';

class OfflineAttendanceService {
  static final OfflineAttendanceService _instance = OfflineAttendanceService._internal();
  factory OfflineAttendanceService() => _instance;
  static OfflineAttendanceService get instance => _instance;

  OfflineAttendanceService._internal();

  Database? _db;
  final APIService _api = APIService();

  Future<Database> get database async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'attendance_offline.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE punches (
          attendance_id TEXT PRIMARY KEY,
          uid TEXT,
          type TEXT,
          time TEXT,
          lat REAL,
          lng REAL,
          address TEXT,
          device_id TEXT,
          device_model TEXT,
          device_brand TEXT,
          device_platform TEXT,
          device_version TEXT,
          device_identifier TEXT,
          device_ip TEXT,
          battery_level INTEGER,
          tenant TEXT,
          is_synced INTEGER,
          retry_count INTEGER,
          last_sync_attempt TEXT
        )
      ''');
    });
    return _db!;
  }

  Future<void> insertPunch(AttendancePunchModel punch) async {
    final db = await database;
    await db.insert('punches', punch.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AttendancePunchModel>> getPendingPunches() async {
    final db = await database;
    final rows = await db.query('punches', where: 'is_synced = ?', whereArgs: [0]);
    return rows.map((r) => AttendancePunchModel.fromMap(r)).toList();
  }

  Future<void> markSynced(String attendanceId) async {
    final db = await database;
    await db.update('punches', {'is_synced': 1}, where: 'attendance_id = ?', whereArgs: [attendanceId]);
  }

  Future<void> incrementRetry(String attendanceId) async {
    final db = await database;
    await db.rawUpdate('UPDATE punches SET retry_count = retry_count + 1 WHERE attendance_id = ?', [attendanceId]);
  }

  Future<void> deletePunch(String attendanceId) async {
    final db = await database;
    await db.delete('punches', where: 'attendance_id = ?', whereArgs: [attendanceId]);
  }

  /// Attempt to sync all pending punches. Returns number of successes.
  Future<int> syncPending({int maxAttempts = 3}) async {
    final pending = await getPendingPunches();
    int success = 0;
    for (final p in pending) {
      if (p.retryCount >= maxAttempts) continue;
      try {
        // Call existing APIService method (checkInCheckout) with fields
        final res = await _api.checkInCheckout(
          p.time,
          p.type,
          latitude: p.lat.toString(),
          longitude: p.lng.toString(),
          address: p.address,
        );
        // consider success if response contains status true or message
        if (res is Map && (res['status'] == true || res.containsKey('message'))) {
          await markSynced(p.attendanceId);
          success++;
        } else if (res == null) {
          await incrementRetry(p.attendanceId);
        } else {
          // treat as success if not null
          await markSynced(p.attendanceId);
          success++;
        }
      } catch (_) {
        await incrementRetry(p.attendanceId);
      }
    }
    return success;
  }
}
