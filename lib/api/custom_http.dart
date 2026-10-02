import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as origin_http;
import 'package:cn_pocket_hr/helpers/time_validator.dart';
import 'package:cn_pocket_hr/services/device_details_service.dart';

import 'package:cn_pocket_hr/helpers/app_update_helper.dart';

export 'package:http/http.dart' show Response, Client;

Map<String, String>? _cachedDeviceHeaders;
DateTime? _lastCacheTime;

Future<Map<String, String>> _getDeviceHeaders() async {
  final now = DateTime.now();
  if (_cachedDeviceHeaders != null &&
      _lastCacheTime != null &&
      now.difference(_lastCacheTime!) < const Duration(minutes: 5)) {
    return _cachedDeviceHeaders!;
  }

  try {
    final deviceService = DeviceDetailsService();
    final details = await deviceService.collectAll();
    final dev = details['device'] as Map<String, dynamic>? ?? {};

    final deviceId = (dev['androidId'] ??
            dev['identifierForVendor'] ??
            dev['device'] ??
            '')
        .toString();
    final model = (dev['model'] ?? '').toString();
    final brand = (dev['brand'] ?? '').toString();
    final platform = (dev['platform'] ?? '').toString();
    final version = (dev['systemVersion'] ?? dev['version'] ?? '').toString();
    final identifier =
        (dev['identifierForVendor'] ?? dev['androidId'] ?? '').toString();
    final ip = (details['ip'] ?? '').toString();
    final batteryLevel = (details['battery'] is Map)
        ? (details['battery']['level']?.toString() ?? '')
        : '';

    final headers = <String, String>{};
    if (deviceId.isNotEmpty) {
      headers['device-id'] = deviceId;
    }
    if (model.isNotEmpty) {
      headers['device-model'] = model;
    }
    if (brand.isNotEmpty) {
      headers['device-brand'] = brand;
    }
    if (platform.isNotEmpty) {
      headers['device-platform'] = platform;
    }
    if (version.isNotEmpty) {
      headers['device-version'] = version;
    }
    if (identifier.isNotEmpty) {
      headers['device-identifier'] = identifier;
    }
    if (ip.isNotEmpty) {
      headers['device-ip'] = ip;
    }
    if (batteryLevel.isNotEmpty) {
      headers['battery-level'] = batteryLevel;
    }

    _cachedDeviceHeaders = headers;
    _lastCacheTime = now;
    return headers;
  } catch (e) {
    return _cachedDeviceHeaders ?? {};
  }
}

Future<origin_http.Response> get(Uri url, {Map<String, String>? headers}) async {
  final Map<String, String> finalHeaders = headers != null ? Map.from(headers) : {};
  finalHeaders['Device-Time'] = DateTime.now().toUtc().toIso8601String();

  final deviceHeaders = await _getDeviceHeaders();
  finalHeaders.addAll(deviceHeaders);

  // Keep only standard 'app-version' and remove duplicate 'app_version'
  finalHeaders.remove('app_version');

  debugPrint('[custom_http GET] url => $url');
  debugPrint('[custom_http GET] headers => $finalHeaders');

  final res = await origin_http.get(url, headers: finalHeaders);
  TimeValidator.validate(res);
  AppUpdateHelper.handlePotentialUpdateRequired(res.statusCode, res.body);
  return res;
}

Future<origin_http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final Map<String, String> finalHeaders = headers != null ? Map.from(headers) : {};
  finalHeaders['Device-Time'] = DateTime.now().toUtc().toIso8601String();

  final deviceHeaders = await _getDeviceHeaders();
  finalHeaders.addAll(deviceHeaders);

  // Keep only standard 'app-version' and remove duplicate 'app_version'
  finalHeaders.remove('app_version');

  debugPrint('[custom_http POST] url => $url');
  debugPrint('[custom_http POST] headers => $finalHeaders');

  final res = await origin_http.post(url, headers: finalHeaders, body: body, encoding: encoding);
  TimeValidator.validate(res);
  AppUpdateHelper.handlePotentialUpdateRequired(res.statusCode, res.body);
  return res;
}
