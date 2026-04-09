import 'dart:convert';

class AttendancePunchModel {
  final String attendanceId; // UUID
  final String uid;
  final String type; // checkin / checkout
  final String time; // ISO string

  final double lat;
  final double lng;
  final String address;

  final String deviceId;
  final String deviceModel;
  final String deviceBrand;
  final String devicePlatform;
  final String deviceVersion;
  final String deviceIdentifier;
  final String deviceIp;
  final int batteryLevel;

  final String tenant;

  final int isSynced; // 0 = pending, 1 = synced
  final int retryCount;
  final String? lastSyncAttempt;

  AttendancePunchModel({
    required this.attendanceId,
    required this.uid,
    required this.type,
    required this.time,
    required this.lat,
    required this.lng,
    required this.address,
    required this.deviceId,
    required this.deviceModel,
    required this.deviceBrand,
    required this.devicePlatform,
    required this.deviceVersion,
    required this.deviceIdentifier,
    required this.deviceIp,
    required this.batteryLevel,
    required this.tenant,
    this.isSynced = 0,
    this.retryCount = 0,
    this.lastSyncAttempt,
  });

  Map<String, dynamic> toMap() {
    return {
      'attendance_id': attendanceId,
      'uid': uid,
      'type': type,
      'time': time,
      'lat': lat,
      'lng': lng,
      'address': address,
      'device_id': deviceId,
      'device_model': deviceModel,
      'device_brand': deviceBrand,
      'device_platform': devicePlatform,
      'device_version': deviceVersion,
      'device_identifier': deviceIdentifier,
      'device_ip': deviceIp,
      'battery_level': batteryLevel,
      'tenant': tenant,
      'is_synced': isSynced,
      'retry_count': retryCount,
      'last_sync_attempt': lastSyncAttempt,
    };
  }

  factory AttendancePunchModel.fromMap(Map<String, dynamic> map) {
    return AttendancePunchModel(
      attendanceId: map['attendance_id'],
      uid: map['uid'],
      type: map['type'],
      time: map['time'],
      lat: map['lat'],
      lng: map['lng'],
      address: map['address'],
      deviceId: map['device_id'],
      deviceModel: map['device_model'],
      deviceBrand: map['device_brand'],
      devicePlatform: map['device_platform'],
      deviceVersion: map['device_version'],
      deviceIdentifier: map['device_identifier'],
      deviceIp: map['device_ip'],
      batteryLevel: map['battery_level'],
      tenant: map['tenant'],
      isSynced: map['is_synced'],
      retryCount: map['retry_count'],
      lastSyncAttempt: map['last_sync_attempt'],
    );
  }

  /// API body builder (matches your backend)
  Map<String, dynamic> toApiBody() {
    return {
      "attendance_id": attendanceId,
      "uid": uid,
      type == "checkin" ? "checkin_at" : "checkout_at": time,
      "lat": lat,
      "lng": lng,
      "address": address,
      "device_id": deviceId,
      "device_model": deviceModel,
      "device_brand": deviceBrand,
      "device_platform": devicePlatform,
      "device_version": deviceVersion,
      "device_identifier": deviceIdentifier,
      "device_ip": deviceIp,
      "battery_level": batteryLevel,
      "tenant": tenant,
    };
  }

  String toJson() => jsonEncode(toMap());
}