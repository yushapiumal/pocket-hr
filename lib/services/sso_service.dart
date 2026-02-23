import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:cn_pocket_hr/services/device_details_service.dart';

class SsoResult {
  final String accessToken;
  final String refreshToken;

  const SsoResult({required this.accessToken, required this.refreshToken});
}

class SsoService {
  static const String _baseUrl = 'https://api.human.go.digitable.io/human/v2/api';

  static final _storage = FlutterSecureStorage();
  static final LocalStorage _fallbackStorage = LocalStorage('pocketHR');
  static final AppLinks _appLinks = AppLinks();

  static const _kVerifierKey = 'sso_pkce_verifier';
  static const _kStateKey = 'sso_state';
  static const _kTenantKey = 'sso_tenant';
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';


  static const String expectedRedirectExample =
      'humanmahajana://callback/mahajana/pocket-hr/callback?code=...&state=...';

  Future<void> _writeSecure({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint('[SSO] secureStorage.write ok key=$key');
    } on MissingPluginException catch (e) {
      debugPrint('[SSO][WARN] secureStorage missing plugin, fallback LocalStorage. $e');
      await _fallbackStorage.ready;
      _fallbackStorage.setItem(key, value);
    }
  }

  Future<void> _deleteSecure({required String key}) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      await _fallbackStorage.ready;
      _fallbackStorage.deleteItem(key);
    }
  }

  Future<SsoResult> signIn({required String tenant}) async {
    debugPrint('[SSO] expected redirect example: $expectedRedirectExample');
    debugPrint('[SSO] signIn: start tenant="$tenant"');

    // collect device details and include in mobile-start request
    Map<String, dynamic>? deviceInfoForApi;
    try {
      final deviceService = DeviceDetailsService();
      final details = await deviceService.collectAll();
      final dev = details['device'] as Map<String, dynamic>? ?? {};
      final deviceId = dev['androidId'] ?? dev['identifierForVendor'] ?? dev['device'] ?? '';
      final model = dev['model'] ?? '';
    //  final brand = dev['brand'] ?? '';
      //final platform = dev['platform'] ?? '';
     // final version = dev['version'] ?? '';
     // final identifier = dev['identifierForVendor'] ?? '';

      // include ip and battery summary if available
    //  final ip = details['ip']?.toString() ?? '';
     // final batteryLevel = (details['battery'] is Map) ? (details['battery']['level']?.toString() ?? '') : '';

      if ((deviceId ?? '').toString().isNotEmpty || (model ?? '').toString().isNotEmpty) {
        deviceInfoForApi = {
          'device_id': deviceId?.toString() ?? '',
          'model': model?.toString() ?? '',
   
     
        };
      }
    } catch (e) {
      debugPrint('[SSO] device details collection failed: $e');
    }

    final start = await _mobileStart(tenant: tenant, deviceInfo: deviceInfoForApi);

    final verifier = start['verifier']?.toString();
    final state = start['state']?.toString();
    final authUrl = start['authUrl']?.toString();
    debugPrint('[SSO] mobile-start: received keys=' + start.keys.join(','));

    if (verifier == null || verifier.isEmpty) {
      debugPrint('[SSO][ERROR] mobile-start: missing verifier');
      throw Exception('SSO start did not return verifier');
    }
    if (state == null || state.isEmpty) {
      debugPrint('[SSO][ERROR] mobile-start: missing state');
      throw Exception('SSO start did not return state');
    }
    if (authUrl == null || authUrl.isEmpty) {
      debugPrint('[SSO][ERROR] mobile-start: missing authUrl');
      throw Exception('SSO start did not return authUrl');
    }

    await _writeSecure(key: _kVerifierKey, value: verifier);
    await _writeSecure(key: _kStateKey, value: state);
    await _writeSecure(key: _kTenantKey, value: tenant);
    debugPrint('[SSO] stored verifier/state/tenant');

    debugPrint('[SSO] opening authUrl');
    await _openAuthUrl(authUrl);
    debugPrint('[SSO] authUrl opened, waiting for redirect...');

    final redirect = await _awaitRedirect(expectedState: state);
    debugPrint('[SSO] redirect received: ${redirect.toString()}');

    final code = redirect.queryParameters['code'];
    final returnedState = redirect.queryParameters['state'];

    if (code == null || code.isEmpty) {
      debugPrint('[SSO][ERROR] redirect missing code');
      throw Exception('SSO redirect missing code');
    }
    if (returnedState == null || returnedState.isEmpty) {
      debugPrint('[SSO][ERROR] redirect missing state');
      throw Exception('SSO redirect missing state');
    }

    if (returnedState != state) {
      debugPrint('[SSO][ERROR] invalid state: expected=$state got=$returnedState');
      throw Exception('Invalid SSO state');
    }

    debugPrint('[SSO] state validated, exchanging code for tokens...');
    final callback = await _mobileCallback(
      tenant: tenant,
      code: code,
      state: returnedState,
      verifier: verifier,
    );

    debugPrint('[SSO] mobile-callback: received keys=' + callback.keys.join(','));

    final accessToken = callback['access_token']?.toString();
    final refreshToken = callback['refresh_token']?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('[SSO][ERROR] mobile-callback missing access_token');
      throw Exception('SSO callback did not return access_token');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('[SSO][ERROR] mobile-callback missing refresh_token');
      throw Exception('SSO callback did not return refresh_token');
    }

    await _writeSecure(key: _kAccessTokenKey, value: accessToken);
    await _writeSecure(key: _kRefreshTokenKey, value: refreshToken);
    debugPrint('[SSO] tokens stored');

    debugPrint('[SSO] signIn: success');
    return SsoResult(accessToken: accessToken, refreshToken: refreshToken);
  }

  String _truncate(String s, {int max = 2000}) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}...<truncated ${s.length - max} chars>';
  }


  Future<Map<String, dynamic>> _mobileStart({required String tenant, Map<String, dynamic>? deviceInfo}) async {
    final uri = Uri.parse('$_baseUrl/sso/mobile-start');
    debugPrint('[SSO] POST $uri');

    final body = <String, dynamic>{'tenant': tenant};
    if (deviceInfo != null && deviceInfo.isNotEmpty) {
      body.addAll(deviceInfo);
    }
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
print(body);
    debugPrint('[SSO] mobile-start status=${res.statusCode}');
    debugPrint('[SSO] mobile-start body=${_truncate(res.body)}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to start SSO (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      debugPrint('[SSO][ERROR] mobile-start invalid json type');
      throw Exception('Invalid SSO start response');
    }

    return decoded;
  }

  Future<Map<String, dynamic>> _mobileCallback({
    required String tenant,
    required String code,
    required String state,
    required String verifier,
  }) async {
    final uri = Uri.parse('$_baseUrl/sso/mobile-callback');
    debugPrint('[SSO] POST $uri');

    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenant': tenant,
        'code': code,
        'state': state,
        'verifier': verifier,
      }),
    );

    debugPrint('[SSO] mobile-callback status=${res.statusCode}');
    debugPrint('[SSO] mobile-callback body=${_truncate(res.body)}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to complete SSO (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      debugPrint('[SSO][ERROR] mobile-callback invalid json type');
      throw Exception('Invalid SSO callback response');
    }

    return decoded;
  }

  Future<void> _openAuthUrl(String authUrl) async {
    final uri = Uri.parse(authUrl);
    debugPrint('[SSO] launchUrl: $uri');

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      debugPrint('[SSO][ERROR] launchUrl failed');
      throw Exception('Could not open authUrl');
    }
  }

  Future<Uri> _awaitRedirect({required String expectedState}) async {
    debugPrint('[SSO] awaiting redirect (expected state=$expectedState)');
    debugPrint('[SSO] expected redirect example: $expectedRedirectExample');

    // Try initial/cold-start link.
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('[SSO] initialLink: $initial');
        debugPrint('[SSO] initialLink params: ${initial.queryParameters}');
        final st = initial.queryParameters['state'];
        if (st == expectedState && initial.queryParameters['code'] != null) {
          debugPrint('[SSO] initialLink matched expected state');
          return initial;
        }
      }
    } catch (e) {
      debugPrint('[SSO] getInitialLink error: $e');
    }

    final completer = Completer<Uri>();
    StreamSubscription<Uri>? sub;

    sub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[SSO] uriLinkStream event: $uri');
        debugPrint('[SSO] uriLinkStream params: ${uri.queryParameters}');
        final st = uri.queryParameters['state'];
        final code = uri.queryParameters['code'];
        if (st == expectedState && code != null && code.isNotEmpty) {
          debugPrint('[SSO] redirect matched expected state');
          if (!completer.isCompleted) completer.complete(uri);
          sub?.cancel();
        }
      },
      onError: (err) {
        debugPrint('[SSO][ERROR] uriLinkStream error: $err');
        if (!completer.isCompleted) {
          completer.completeError(err);
        }
        sub?.cancel();
      },
    );

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        debugPrint('[SSO][ERROR] redirect wait timeout');
        sub?.cancel();
        throw Exception('SSO timed out');
      },
    );
  }

  @visibleForTesting
  Future<void> clearStoredSso() async {
    await _deleteSecure(key: _kVerifierKey);
    await _deleteSecure(key: _kStateKey);
    await _deleteSecure(key: _kTenantKey);
  }
}
