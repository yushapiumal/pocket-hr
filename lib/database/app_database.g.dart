// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PunchesTable extends Punches with TableInfo<$PunchesTable, Punche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PunchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attendanceIdMeta =
      const VerificationMeta('attendanceId');
  @override
  late final GeneratedColumn<String> attendanceId = GeneratedColumn<String>(
      'attendance_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deviceModelMeta =
      const VerificationMeta('deviceModel');
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
      'device_model', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deviceBrandMeta =
      const VerificationMeta('deviceBrand');
  @override
  late final GeneratedColumn<String> deviceBrand = GeneratedColumn<String>(
      'device_brand', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _devicePlatformMeta =
      const VerificationMeta('devicePlatform');
  @override
  late final GeneratedColumn<String> devicePlatform = GeneratedColumn<String>(
      'device_platform', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deviceVersionMeta =
      const VerificationMeta('deviceVersion');
  @override
  late final GeneratedColumn<String> deviceVersion = GeneratedColumn<String>(
      'device_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deviceIdentifierMeta =
      const VerificationMeta('deviceIdentifier');
  @override
  late final GeneratedColumn<String> deviceIdentifier = GeneratedColumn<String>(
      'device_identifier', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deviceIpMeta =
      const VerificationMeta('deviceIp');
  @override
  late final GeneratedColumn<String> deviceIp = GeneratedColumn<String>(
      'device_ip', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _batteryLevelMeta =
      const VerificationMeta('batteryLevel');
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
      'battery_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tenantMeta = const VerificationMeta('tenant');
  @override
  late final GeneratedColumn<String> tenant = GeneratedColumn<String>(
      'tenant', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isRemoteMeta =
      const VerificationMeta('isRemote');
  @override
  late final GeneratedColumn<int> isRemote = GeneratedColumn<int>(
      'is_remote', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSyncAttemptMeta =
      const VerificationMeta('lastSyncAttempt');
  @override
  late final GeneratedColumn<String> lastSyncAttempt = GeneratedColumn<String>(
      'last_sync_attempt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        attendanceId,
        uid,
        type,
        time,
        lat,
        lng,
        address,
        deviceId,
        deviceModel,
        deviceBrand,
        devicePlatform,
        deviceVersion,
        deviceIdentifier,
        deviceIp,
        batteryLevel,
        tenant,
        isRemote,
        isSynced,
        retryCount,
        lastSyncAttempt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'punches';
  @override
  VerificationContext validateIntegrity(Insertable<Punche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attendance_id')) {
      context.handle(
          _attendanceIdMeta,
          attendanceId.isAcceptableOrUnknown(
              data['attendance_id']!, _attendanceIdMeta));
    } else if (isInserting) {
      context.missing(_attendanceIdMeta);
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('device_model')) {
      context.handle(
          _deviceModelMeta,
          deviceModel.isAcceptableOrUnknown(
              data['device_model']!, _deviceModelMeta));
    }
    if (data.containsKey('device_brand')) {
      context.handle(
          _deviceBrandMeta,
          deviceBrand.isAcceptableOrUnknown(
              data['device_brand']!, _deviceBrandMeta));
    }
    if (data.containsKey('device_platform')) {
      context.handle(
          _devicePlatformMeta,
          devicePlatform.isAcceptableOrUnknown(
              data['device_platform']!, _devicePlatformMeta));
    }
    if (data.containsKey('device_version')) {
      context.handle(
          _deviceVersionMeta,
          deviceVersion.isAcceptableOrUnknown(
              data['device_version']!, _deviceVersionMeta));
    }
    if (data.containsKey('device_identifier')) {
      context.handle(
          _deviceIdentifierMeta,
          deviceIdentifier.isAcceptableOrUnknown(
              data['device_identifier']!, _deviceIdentifierMeta));
    }
    if (data.containsKey('device_ip')) {
      context.handle(_deviceIpMeta,
          deviceIp.isAcceptableOrUnknown(data['device_ip']!, _deviceIpMeta));
    }
    if (data.containsKey('battery_level')) {
      context.handle(
          _batteryLevelMeta,
          batteryLevel.isAcceptableOrUnknown(
              data['battery_level']!, _batteryLevelMeta));
    }
    if (data.containsKey('tenant')) {
      context.handle(_tenantMeta,
          tenant.isAcceptableOrUnknown(data['tenant']!, _tenantMeta));
    }
    if (data.containsKey('is_remote')) {
      context.handle(_isRemoteMeta,
          isRemote.isAcceptableOrUnknown(data['is_remote']!, _isRemoteMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_sync_attempt')) {
      context.handle(
          _lastSyncAttemptMeta,
          lastSyncAttempt.isAcceptableOrUnknown(
              data['last_sync_attempt']!, _lastSyncAttemptMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attendanceId};
  @override
  Punche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Punche(
      attendanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attendance_id'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      deviceModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_model'])!,
      deviceBrand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_brand'])!,
      devicePlatform: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_platform'])!,
      deviceVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_version'])!,
      deviceIdentifier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_identifier'])!,
      deviceIp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_ip'])!,
      batteryLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_level'])!,
      tenant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant'])!,
      isRemote: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_remote'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_synced'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastSyncAttempt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_sync_attempt']),
    );
  }

  @override
  $PunchesTable createAlias(String alias) {
    return $PunchesTable(attachedDatabase, alias);
  }
}

class Punche extends DataClass implements Insertable<Punche> {
  final String attendanceId;
  final String uid;
  final String type;
  final String time;
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
  final int isRemote;
  final int isSynced;
  final int retryCount;
  final String? lastSyncAttempt;
  const Punche(
      {required this.attendanceId,
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
      required this.isRemote,
      required this.isSynced,
      required this.retryCount,
      this.lastSyncAttempt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attendance_id'] = Variable<String>(attendanceId);
    map['uid'] = Variable<String>(uid);
    map['type'] = Variable<String>(type);
    map['time'] = Variable<String>(time);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['address'] = Variable<String>(address);
    map['device_id'] = Variable<String>(deviceId);
    map['device_model'] = Variable<String>(deviceModel);
    map['device_brand'] = Variable<String>(deviceBrand);
    map['device_platform'] = Variable<String>(devicePlatform);
    map['device_version'] = Variable<String>(deviceVersion);
    map['device_identifier'] = Variable<String>(deviceIdentifier);
    map['device_ip'] = Variable<String>(deviceIp);
    map['battery_level'] = Variable<int>(batteryLevel);
    map['tenant'] = Variable<String>(tenant);
    map['is_remote'] = Variable<int>(isRemote);
    map['is_synced'] = Variable<int>(isSynced);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastSyncAttempt != null) {
      map['last_sync_attempt'] = Variable<String>(lastSyncAttempt);
    }
    return map;
  }

  PunchesCompanion toCompanion(bool nullToAbsent) {
    return PunchesCompanion(
      attendanceId: Value(attendanceId),
      uid: Value(uid),
      type: Value(type),
      time: Value(time),
      lat: Value(lat),
      lng: Value(lng),
      address: Value(address),
      deviceId: Value(deviceId),
      deviceModel: Value(deviceModel),
      deviceBrand: Value(deviceBrand),
      devicePlatform: Value(devicePlatform),
      deviceVersion: Value(deviceVersion),
      deviceIdentifier: Value(deviceIdentifier),
      deviceIp: Value(deviceIp),
      batteryLevel: Value(batteryLevel),
      tenant: Value(tenant),
      isRemote: Value(isRemote),
      isSynced: Value(isSynced),
      retryCount: Value(retryCount),
      lastSyncAttempt: lastSyncAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAttempt),
    );
  }

  factory Punche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Punche(
      attendanceId: serializer.fromJson<String>(json['attendanceId']),
      uid: serializer.fromJson<String>(json['uid']),
      type: serializer.fromJson<String>(json['type']),
      time: serializer.fromJson<String>(json['time']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      address: serializer.fromJson<String>(json['address']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceModel: serializer.fromJson<String>(json['deviceModel']),
      deviceBrand: serializer.fromJson<String>(json['deviceBrand']),
      devicePlatform: serializer.fromJson<String>(json['devicePlatform']),
      deviceVersion: serializer.fromJson<String>(json['deviceVersion']),
      deviceIdentifier: serializer.fromJson<String>(json['deviceIdentifier']),
      deviceIp: serializer.fromJson<String>(json['deviceIp']),
      batteryLevel: serializer.fromJson<int>(json['batteryLevel']),
      tenant: serializer.fromJson<String>(json['tenant']),
      isRemote: serializer.fromJson<int>(json['isRemote']),
      isSynced: serializer.fromJson<int>(json['isSynced']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastSyncAttempt: serializer.fromJson<String?>(json['lastSyncAttempt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attendanceId': serializer.toJson<String>(attendanceId),
      'uid': serializer.toJson<String>(uid),
      'type': serializer.toJson<String>(type),
      'time': serializer.toJson<String>(time),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'address': serializer.toJson<String>(address),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceModel': serializer.toJson<String>(deviceModel),
      'deviceBrand': serializer.toJson<String>(deviceBrand),
      'devicePlatform': serializer.toJson<String>(devicePlatform),
      'deviceVersion': serializer.toJson<String>(deviceVersion),
      'deviceIdentifier': serializer.toJson<String>(deviceIdentifier),
      'deviceIp': serializer.toJson<String>(deviceIp),
      'batteryLevel': serializer.toJson<int>(batteryLevel),
      'tenant': serializer.toJson<String>(tenant),
      'isRemote': serializer.toJson<int>(isRemote),
      'isSynced': serializer.toJson<int>(isSynced),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastSyncAttempt': serializer.toJson<String?>(lastSyncAttempt),
    };
  }

  Punche copyWith(
          {String? attendanceId,
          String? uid,
          String? type,
          String? time,
          double? lat,
          double? lng,
          String? address,
          String? deviceId,
          String? deviceModel,
          String? deviceBrand,
          String? devicePlatform,
          String? deviceVersion,
          String? deviceIdentifier,
          String? deviceIp,
          int? batteryLevel,
          String? tenant,
          int? isRemote,
          int? isSynced,
          int? retryCount,
          Value<String?> lastSyncAttempt = const Value.absent()}) =>
      Punche(
        attendanceId: attendanceId ?? this.attendanceId,
        uid: uid ?? this.uid,
        type: type ?? this.type,
        time: time ?? this.time,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
        deviceId: deviceId ?? this.deviceId,
        deviceModel: deviceModel ?? this.deviceModel,
        deviceBrand: deviceBrand ?? this.deviceBrand,
        devicePlatform: devicePlatform ?? this.devicePlatform,
        deviceVersion: deviceVersion ?? this.deviceVersion,
        deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
        deviceIp: deviceIp ?? this.deviceIp,
        batteryLevel: batteryLevel ?? this.batteryLevel,
        tenant: tenant ?? this.tenant,
        isRemote: isRemote ?? this.isRemote,
        isSynced: isSynced ?? this.isSynced,
        retryCount: retryCount ?? this.retryCount,
        lastSyncAttempt: lastSyncAttempt.present
            ? lastSyncAttempt.value
            : this.lastSyncAttempt,
      );
  Punche copyWithCompanion(PunchesCompanion data) {
    return Punche(
      attendanceId: data.attendanceId.present
          ? data.attendanceId.value
          : this.attendanceId,
      uid: data.uid.present ? data.uid.value : this.uid,
      type: data.type.present ? data.type.value : this.type,
      time: data.time.present ? data.time.value : this.time,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      address: data.address.present ? data.address.value : this.address,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
      deviceBrand:
          data.deviceBrand.present ? data.deviceBrand.value : this.deviceBrand,
      devicePlatform: data.devicePlatform.present
          ? data.devicePlatform.value
          : this.devicePlatform,
      deviceVersion: data.deviceVersion.present
          ? data.deviceVersion.value
          : this.deviceVersion,
      deviceIdentifier: data.deviceIdentifier.present
          ? data.deviceIdentifier.value
          : this.deviceIdentifier,
      deviceIp: data.deviceIp.present ? data.deviceIp.value : this.deviceIp,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      tenant: data.tenant.present ? data.tenant.value : this.tenant,
      isRemote: data.isRemote.present ? data.isRemote.value : this.isRemote,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastSyncAttempt: data.lastSyncAttempt.present
          ? data.lastSyncAttempt.value
          : this.lastSyncAttempt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Punche(')
          ..write('attendanceId: $attendanceId, ')
          ..write('uid: $uid, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('address: $address, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('deviceBrand: $deviceBrand, ')
          ..write('devicePlatform: $devicePlatform, ')
          ..write('deviceVersion: $deviceVersion, ')
          ..write('deviceIdentifier: $deviceIdentifier, ')
          ..write('deviceIp: $deviceIp, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('tenant: $tenant, ')
          ..write('isRemote: $isRemote, ')
          ..write('isSynced: $isSynced, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastSyncAttempt: $lastSyncAttempt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      attendanceId,
      uid,
      type,
      time,
      lat,
      lng,
      address,
      deviceId,
      deviceModel,
      deviceBrand,
      devicePlatform,
      deviceVersion,
      deviceIdentifier,
      deviceIp,
      batteryLevel,
      tenant,
      isRemote,
      isSynced,
      retryCount,
      lastSyncAttempt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Punche &&
          other.attendanceId == this.attendanceId &&
          other.uid == this.uid &&
          other.type == this.type &&
          other.time == this.time &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.address == this.address &&
          other.deviceId == this.deviceId &&
          other.deviceModel == this.deviceModel &&
          other.deviceBrand == this.deviceBrand &&
          other.devicePlatform == this.devicePlatform &&
          other.deviceVersion == this.deviceVersion &&
          other.deviceIdentifier == this.deviceIdentifier &&
          other.deviceIp == this.deviceIp &&
          other.batteryLevel == this.batteryLevel &&
          other.tenant == this.tenant &&
          other.isRemote == this.isRemote &&
          other.isSynced == this.isSynced &&
          other.retryCount == this.retryCount &&
          other.lastSyncAttempt == this.lastSyncAttempt);
}

class PunchesCompanion extends UpdateCompanion<Punche> {
  final Value<String> attendanceId;
  final Value<String> uid;
  final Value<String> type;
  final Value<String> time;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> address;
  final Value<String> deviceId;
  final Value<String> deviceModel;
  final Value<String> deviceBrand;
  final Value<String> devicePlatform;
  final Value<String> deviceVersion;
  final Value<String> deviceIdentifier;
  final Value<String> deviceIp;
  final Value<int> batteryLevel;
  final Value<String> tenant;
  final Value<int> isRemote;
  final Value<int> isSynced;
  final Value<int> retryCount;
  final Value<String?> lastSyncAttempt;
  final Value<int> rowid;
  const PunchesCompanion({
    this.attendanceId = const Value.absent(),
    this.uid = const Value.absent(),
    this.type = const Value.absent(),
    this.time = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.address = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.deviceBrand = const Value.absent(),
    this.devicePlatform = const Value.absent(),
    this.deviceVersion = const Value.absent(),
    this.deviceIdentifier = const Value.absent(),
    this.deviceIp = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.tenant = const Value.absent(),
    this.isRemote = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PunchesCompanion.insert({
    required String attendanceId,
    required String uid,
    required String type,
    required String time,
    required double lat,
    required double lng,
    required String address,
    this.deviceId = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.deviceBrand = const Value.absent(),
    this.devicePlatform = const Value.absent(),
    this.deviceVersion = const Value.absent(),
    this.deviceIdentifier = const Value.absent(),
    this.deviceIp = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.tenant = const Value.absent(),
    this.isRemote = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : attendanceId = Value(attendanceId),
        uid = Value(uid),
        type = Value(type),
        time = Value(time),
        lat = Value(lat),
        lng = Value(lng),
        address = Value(address);
  static Insertable<Punche> custom({
    Expression<String>? attendanceId,
    Expression<String>? uid,
    Expression<String>? type,
    Expression<String>? time,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? address,
    Expression<String>? deviceId,
    Expression<String>? deviceModel,
    Expression<String>? deviceBrand,
    Expression<String>? devicePlatform,
    Expression<String>? deviceVersion,
    Expression<String>? deviceIdentifier,
    Expression<String>? deviceIp,
    Expression<int>? batteryLevel,
    Expression<String>? tenant,
    Expression<int>? isRemote,
    Expression<int>? isSynced,
    Expression<int>? retryCount,
    Expression<String>? lastSyncAttempt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attendanceId != null) 'attendance_id': attendanceId,
      if (uid != null) 'uid': uid,
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (address != null) 'address': address,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceBrand != null) 'device_brand': deviceBrand,
      if (devicePlatform != null) 'device_platform': devicePlatform,
      if (deviceVersion != null) 'device_version': deviceVersion,
      if (deviceIdentifier != null) 'device_identifier': deviceIdentifier,
      if (deviceIp != null) 'device_ip': deviceIp,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (tenant != null) 'tenant': tenant,
      if (isRemote != null) 'is_remote': isRemote,
      if (isSynced != null) 'is_synced': isSynced,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastSyncAttempt != null) 'last_sync_attempt': lastSyncAttempt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PunchesCompanion copyWith(
      {Value<String>? attendanceId,
      Value<String>? uid,
      Value<String>? type,
      Value<String>? time,
      Value<double>? lat,
      Value<double>? lng,
      Value<String>? address,
      Value<String>? deviceId,
      Value<String>? deviceModel,
      Value<String>? deviceBrand,
      Value<String>? devicePlatform,
      Value<String>? deviceVersion,
      Value<String>? deviceIdentifier,
      Value<String>? deviceIp,
      Value<int>? batteryLevel,
      Value<String>? tenant,
      Value<int>? isRemote,
      Value<int>? isSynced,
      Value<int>? retryCount,
      Value<String?>? lastSyncAttempt,
      Value<int>? rowid}) {
    return PunchesCompanion(
      attendanceId: attendanceId ?? this.attendanceId,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      time: time ?? this.time,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      deviceId: deviceId ?? this.deviceId,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      devicePlatform: devicePlatform ?? this.devicePlatform,
      deviceVersion: deviceVersion ?? this.deviceVersion,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      deviceIp: deviceIp ?? this.deviceIp,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      tenant: tenant ?? this.tenant,
      isRemote: isRemote ?? this.isRemote,
      isSynced: isSynced ?? this.isSynced,
      retryCount: retryCount ?? this.retryCount,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attendanceId.present) {
      map['attendance_id'] = Variable<String>(attendanceId.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (deviceBrand.present) {
      map['device_brand'] = Variable<String>(deviceBrand.value);
    }
    if (devicePlatform.present) {
      map['device_platform'] = Variable<String>(devicePlatform.value);
    }
    if (deviceVersion.present) {
      map['device_version'] = Variable<String>(deviceVersion.value);
    }
    if (deviceIdentifier.present) {
      map['device_identifier'] = Variable<String>(deviceIdentifier.value);
    }
    if (deviceIp.present) {
      map['device_ip'] = Variable<String>(deviceIp.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (tenant.present) {
      map['tenant'] = Variable<String>(tenant.value);
    }
    if (isRemote.present) {
      map['is_remote'] = Variable<int>(isRemote.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastSyncAttempt.present) {
      map['last_sync_attempt'] = Variable<String>(lastSyncAttempt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PunchesCompanion(')
          ..write('attendanceId: $attendanceId, ')
          ..write('uid: $uid, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('address: $address, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('deviceBrand: $deviceBrand, ')
          ..write('devicePlatform: $devicePlatform, ')
          ..write('deviceVersion: $deviceVersion, ')
          ..write('deviceIdentifier: $deviceIdentifier, ')
          ..write('deviceIp: $deviceIp, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('tenant: $tenant, ')
          ..write('isRemote: $isRemote, ')
          ..write('isSynced: $isSynced, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PunchesTable punches = $PunchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [punches];
}

typedef $$PunchesTableCreateCompanionBuilder = PunchesCompanion Function({
  required String attendanceId,
  required String uid,
  required String type,
  required String time,
  required double lat,
  required double lng,
  required String address,
  Value<String> deviceId,
  Value<String> deviceModel,
  Value<String> deviceBrand,
  Value<String> devicePlatform,
  Value<String> deviceVersion,
  Value<String> deviceIdentifier,
  Value<String> deviceIp,
  Value<int> batteryLevel,
  Value<String> tenant,
  Value<int> isRemote,
  Value<int> isSynced,
  Value<int> retryCount,
  Value<String?> lastSyncAttempt,
  Value<int> rowid,
});
typedef $$PunchesTableUpdateCompanionBuilder = PunchesCompanion Function({
  Value<String> attendanceId,
  Value<String> uid,
  Value<String> type,
  Value<String> time,
  Value<double> lat,
  Value<double> lng,
  Value<String> address,
  Value<String> deviceId,
  Value<String> deviceModel,
  Value<String> deviceBrand,
  Value<String> devicePlatform,
  Value<String> deviceVersion,
  Value<String> deviceIdentifier,
  Value<String> deviceIp,
  Value<int> batteryLevel,
  Value<String> tenant,
  Value<int> isRemote,
  Value<int> isSynced,
  Value<int> retryCount,
  Value<String?> lastSyncAttempt,
  Value<int> rowid,
});

class $$PunchesTableFilterComposer
    extends Composer<_$AppDatabase, $PunchesTable> {
  $$PunchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attendanceId => $composableBuilder(
      column: $table.attendanceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devicePlatform => $composableBuilder(
      column: $table.devicePlatform,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceVersion => $composableBuilder(
      column: $table.deviceVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceIdentifier => $composableBuilder(
      column: $table.deviceIdentifier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceIp => $composableBuilder(
      column: $table.deviceIp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get batteryLevel => $composableBuilder(
      column: $table.batteryLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenant => $composableBuilder(
      column: $table.tenant, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isRemote => $composableBuilder(
      column: $table.isRemote, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncAttempt => $composableBuilder(
      column: $table.lastSyncAttempt,
      builder: (column) => ColumnFilters(column));
}

class $$PunchesTableOrderingComposer
    extends Composer<_$AppDatabase, $PunchesTable> {
  $$PunchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attendanceId => $composableBuilder(
      column: $table.attendanceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devicePlatform => $composableBuilder(
      column: $table.devicePlatform,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceVersion => $composableBuilder(
      column: $table.deviceVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceIdentifier => $composableBuilder(
      column: $table.deviceIdentifier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceIp => $composableBuilder(
      column: $table.deviceIp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
      column: $table.batteryLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenant => $composableBuilder(
      column: $table.tenant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isRemote => $composableBuilder(
      column: $table.isRemote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncAttempt => $composableBuilder(
      column: $table.lastSyncAttempt,
      builder: (column) => ColumnOrderings(column));
}

class $$PunchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PunchesTable> {
  $$PunchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attendanceId => $composableBuilder(
      column: $table.attendanceId, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => column);

  GeneratedColumn<String> get deviceBrand => $composableBuilder(
      column: $table.deviceBrand, builder: (column) => column);

  GeneratedColumn<String> get devicePlatform => $composableBuilder(
      column: $table.devicePlatform, builder: (column) => column);

  GeneratedColumn<String> get deviceVersion => $composableBuilder(
      column: $table.deviceVersion, builder: (column) => column);

  GeneratedColumn<String> get deviceIdentifier => $composableBuilder(
      column: $table.deviceIdentifier, builder: (column) => column);

  GeneratedColumn<String> get deviceIp =>
      $composableBuilder(column: $table.deviceIp, builder: (column) => column);

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
      column: $table.batteryLevel, builder: (column) => column);

  GeneratedColumn<String> get tenant =>
      $composableBuilder(column: $table.tenant, builder: (column) => column);

  GeneratedColumn<int> get isRemote =>
      $composableBuilder(column: $table.isRemote, builder: (column) => column);

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastSyncAttempt => $composableBuilder(
      column: $table.lastSyncAttempt, builder: (column) => column);
}

class $$PunchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PunchesTable,
    Punche,
    $$PunchesTableFilterComposer,
    $$PunchesTableOrderingComposer,
    $$PunchesTableAnnotationComposer,
    $$PunchesTableCreateCompanionBuilder,
    $$PunchesTableUpdateCompanionBuilder,
    (Punche, BaseReferences<_$AppDatabase, $PunchesTable, Punche>),
    Punche,
    PrefetchHooks Function()> {
  $$PunchesTableTableManager(_$AppDatabase db, $PunchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PunchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PunchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PunchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> attendanceId = const Value.absent(),
            Value<String> uid = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> deviceModel = const Value.absent(),
            Value<String> deviceBrand = const Value.absent(),
            Value<String> devicePlatform = const Value.absent(),
            Value<String> deviceVersion = const Value.absent(),
            Value<String> deviceIdentifier = const Value.absent(),
            Value<String> deviceIp = const Value.absent(),
            Value<int> batteryLevel = const Value.absent(),
            Value<String> tenant = const Value.absent(),
            Value<int> isRemote = const Value.absent(),
            Value<int> isSynced = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastSyncAttempt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PunchesCompanion(
            attendanceId: attendanceId,
            uid: uid,
            type: type,
            time: time,
            lat: lat,
            lng: lng,
            address: address,
            deviceId: deviceId,
            deviceModel: deviceModel,
            deviceBrand: deviceBrand,
            devicePlatform: devicePlatform,
            deviceVersion: deviceVersion,
            deviceIdentifier: deviceIdentifier,
            deviceIp: deviceIp,
            batteryLevel: batteryLevel,
            tenant: tenant,
            isRemote: isRemote,
            isSynced: isSynced,
            retryCount: retryCount,
            lastSyncAttempt: lastSyncAttempt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String attendanceId,
            required String uid,
            required String type,
            required String time,
            required double lat,
            required double lng,
            required String address,
            Value<String> deviceId = const Value.absent(),
            Value<String> deviceModel = const Value.absent(),
            Value<String> deviceBrand = const Value.absent(),
            Value<String> devicePlatform = const Value.absent(),
            Value<String> deviceVersion = const Value.absent(),
            Value<String> deviceIdentifier = const Value.absent(),
            Value<String> deviceIp = const Value.absent(),
            Value<int> batteryLevel = const Value.absent(),
            Value<String> tenant = const Value.absent(),
            Value<int> isRemote = const Value.absent(),
            Value<int> isSynced = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastSyncAttempt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PunchesCompanion.insert(
            attendanceId: attendanceId,
            uid: uid,
            type: type,
            time: time,
            lat: lat,
            lng: lng,
            address: address,
            deviceId: deviceId,
            deviceModel: deviceModel,
            deviceBrand: deviceBrand,
            devicePlatform: devicePlatform,
            deviceVersion: deviceVersion,
            deviceIdentifier: deviceIdentifier,
            deviceIp: deviceIp,
            batteryLevel: batteryLevel,
            tenant: tenant,
            isRemote: isRemote,
            isSynced: isSynced,
            retryCount: retryCount,
            lastSyncAttempt: lastSyncAttempt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PunchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PunchesTable,
    Punche,
    $$PunchesTableFilterComposer,
    $$PunchesTableOrderingComposer,
    $$PunchesTableAnnotationComposer,
    $$PunchesTableCreateCompanionBuilder,
    $$PunchesTableUpdateCompanionBuilder,
    (Punche, BaseReferences<_$AppDatabase, $PunchesTable, Punche>),
    Punche,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PunchesTableTableManager get punches =>
      $$PunchesTableTableManager(_db, _db.punches);
}
