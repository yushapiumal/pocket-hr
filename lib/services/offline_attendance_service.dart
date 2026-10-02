import 'dart:async';
import 'package:drift/drift.dart';
import 'package:cn_pocket_hr/database/app_database.dart';
import 'package:cn_pocket_hr/models/hr/check_in_check_out_model.dart';
import 'package:cn_pocket_hr/api/api_service.dart';

class OfflineAttendanceService {
  static final OfflineAttendanceService _instance = OfflineAttendanceService._internal();
  factory OfflineAttendanceService() => _instance;
  static OfflineAttendanceService get instance => _instance;

  OfflineAttendanceService._internal();

  final AppDatabase _db = AppDatabase();
  final APIService _api = APIService();

  AppDatabase get database => _db;

  Future<void> insertPunch(AttendancePunchModel punch) async {
    await _db.into(_db.punches).insertOnConflictUpdate(
          PunchesCompanion.insert(
            attendanceId: punch.attendanceId,
            uid: punch.uid,
            type: punch.type,
            time: punch.time,
            lat: punch.lat,
            lng: punch.lng,
            address: punch.address,
            deviceId: Value(punch.deviceId),
            deviceModel: Value(punch.deviceModel),
            deviceBrand: Value(punch.deviceBrand),
            devicePlatform: Value(punch.devicePlatform),
            deviceVersion: Value(punch.deviceVersion),
            deviceIdentifier: Value(punch.deviceIdentifier),
            deviceIp: Value(punch.deviceIp),
            batteryLevel: Value(punch.batteryLevel),
            tenant: Value(punch.tenant),
            isRemote: Value(punch.isRemote),
            isSynced: Value(punch.isSynced),
            retryCount: Value(punch.retryCount),
            lastSyncAttempt: Value(punch.lastSyncAttempt),
          ),
        );
  }

  Future<List<AttendancePunchModel>> getPendingPunches() async {
    final query = _db.select(_db.punches)..where((tbl) => tbl.isSynced.equals(0));
    final rows = await query.get();
    return rows.map((r) => AttendancePunchModel(
          attendanceId: r.attendanceId,
          uid: r.uid,
          type: r.type,
          time: r.time,
          lat: r.lat,
          lng: r.lng,
          address: r.address,
          deviceId: r.deviceId,
          deviceModel: r.deviceModel,
          deviceBrand: r.deviceBrand,
          devicePlatform: r.devicePlatform,
          deviceVersion: r.deviceVersion,
          deviceIdentifier: r.deviceIdentifier,
          deviceIp: r.deviceIp,
          batteryLevel: r.batteryLevel,
          tenant: r.tenant,
          isRemote: r.isRemote,
          isSynced: r.isSynced,
          retryCount: r.retryCount,
          lastSyncAttempt: r.lastSyncAttempt,
        )).toList();
  }

  Future<void> markSynced(String attendanceId) async {
    await (_db.update(_db.punches)..where((tbl) => tbl.attendanceId.equals(attendanceId)))
        .write(const PunchesCompanion(isSynced: Value(1)));
  }

  Future<void> incrementRetry(String attendanceId) async {
    final query = _db.select(_db.punches)..where((tbl) => tbl.attendanceId.equals(attendanceId));
    final row = await query.getSingleOrNull();
    if (row != null) {
      await (_db.update(_db.punches)..where((tbl) => tbl.attendanceId.equals(attendanceId)))
          .write(PunchesCompanion(retryCount: Value(row.retryCount + 1)));
    }
  }

  Future<void> deletePunch(String attendanceId) async {
    await (_db.delete(_db.punches)..where((tbl) => tbl.attendanceId.equals(attendanceId))).go();
  }

  Future<int> getPendingCount() async {
    try {
      final query = _db.select(_db.punches)..where((tbl) => tbl.isSynced.equals(0));
      final rows = await query.get();
      return rows.length;
    } catch (_) {}
    return 0;
  }

  /// Attempt to sync all pending punches. Returns a Map with 'success' and 'failed' counts.
  Future<Map<String, int>> syncPending({int maxAttempts = 3, bool ignoreMaxAttempts = false}) async {
    final pending = await getPendingPunches();
    int success = 0;
    int failed = 0;
    for (final p in pending) {
      if (!ignoreMaxAttempts && p.retryCount >= maxAttempts) {
        failed++;
        continue;
      }
      try {
        final res = await _api.checkInCheckout(
          p.time,
          p.type,
          latitude: p.lat.toString(),
          longitude: p.lng.toString(),
          address: p.address,
          isRemotePunch: p.isRemote == 1,
        );
        
        bool apiSuccess = false;
        bool isPermanentFailure = false;
        
        if (res is Map) {
          final statusCode = res['status'];
          if (statusCode is num) {
            final code = statusCode.toInt();
            if (code >= 200 && code < 300) {
              apiSuccess = true;
            } else if (code >= 400 && code < 500) {
              isPermanentFailure = true;
            }
          } else if (res['success'] == true) {
            apiSuccess = true;
          }
        }
        
        if (apiSuccess) {
          await markSynced(p.attendanceId);
          success++;
        } else if (isPermanentFailure) {
          await markSynced(p.attendanceId);
          failed++;
        } else {
          await incrementRetry(p.attendanceId);
          failed++;
        }
      } catch (_) {
        await incrementRetry(p.attendanceId);
        failed++;
      }
    }
    return {'success': success, 'failed': failed};
  }

  Future<void> clearAllPunches() async {
    await _db.delete(_db.punches).go();
  }

  Future<void> clearSyncedPunches() async {
    await (_db.delete(_db.punches)..where((tbl) => tbl.isSynced.equals(1))).go();
  }
}
