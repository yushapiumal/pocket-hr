import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide LocalStorage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:app_links/app_links.dart';
import 'package:cn_pocket_hr/services/device_details_service.dart';

class SsoResult {
  final String accessToken;
  final String refreshToken;

  const SsoResult({required this.accessToken, required this.refreshToken});
}

class SsoService {
  static const String _baseUrl =
      'https://api.human.go.digitable.io/human/v2/api';

  static final _storage = FlutterSecureStorage();
  static final LocalStorage _fallbackStorage = LocalStorage('pocketHR');
  static final AppLinks _appLinks = AppLinks();

  static const _kVerifierKey = 'sso_pkce_verifier';
  static const _kStateKey = 'sso_state';
  static const _kTenantKey = 'sso_tenant';
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';

  static const String expectedRedirectExample =
      'r3human://callback/pocket-hr/callback?code=...&state=...';

  Future<void> _writeSecure(
      {required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint('[SSO] secureStorage.write ok key=$key');
    } on MissingPluginException catch (e) {
      debugPrint(
          '[SSO][WARN] secureStorage missing plugin, fallback LocalStorage. $e');
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

  /// Signs in via SSO.
  ///
  /// [context] is required to open the in-app WebView screen.
  Future<SsoResult> signIn({
    required String tenant,
    required BuildContext context,
  }) async {
    debugPrint('[SSO] expected redirect example: $expectedRedirectExample');
    debugPrint('[SSO] signIn: start tenant="$tenant"');

    Map<String, dynamic>? deviceInfoForApi;
    try {
      final deviceService = DeviceDetailsService();
      final details = await deviceService.collectAll();
      final dev = details['device'] as Map<String, dynamic>? ?? {};
      final deviceId =
          dev['androidId'] ?? dev['identifierForVendor'] ?? dev['device'] ?? '';
      final model = dev['model'] ?? '';

      if ((deviceId ?? '').toString().isNotEmpty ||
          (model ?? '').toString().isNotEmpty) {
        deviceInfoForApi = {
          'device_id': deviceId?.toString() ?? '',
          'model': model?.toString() ?? '',
        };
      }
    } catch (e) {
      debugPrint('[SSO] device details collection failed: $e');
    }

    final start =
        await _mobileStart(tenant: tenant, deviceInfo: deviceInfoForApi);

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

    debugPrint('[SSO] opening authUrl (in-app WebView, no address bar)');
    final redirect = await _openAuthUrl(context, authUrl, state);
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
      debugPrint(
          '[SSO][ERROR] invalid state: expected=$state got=$returnedState');
      throw Exception('Invalid SSO state');
    }

    debugPrint('[SSO] state validated, exchanging code for tokens...');
    final callback = await _mobileCallback(
      tenant: tenant,
      code: code,
      state: returnedState,
      verifier: verifier,
    );

    debugPrint(
        '[SSO] mobile-callback: received keys=' + callback.keys.join(','));

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

  Future<Map<String, dynamic>> _mobileStart(
      {required String tenant, Map<String, dynamic>? deviceInfo}) async {
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
    debugPrint('[SSO] mobile-start body=$body');
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

  /// Opens the SSO auth URL in a full-screen in-app WebView (no address bar).
  /// Intercepts the custom-scheme redirect and returns it as a [Uri].
  Future<Uri> _openAuthUrl(
      BuildContext context, String authUrl, String expectedState) async {
    debugPrint(
        '[SSO] openAuthUrl using InAppWebView (no address bar): $authUrl');

    // Detect callback scheme from redirect_uri param in the authUrl
    String callbackScheme = 'r3human';
    try {
      final parsed = Uri.parse(authUrl);
      final redirectParam = parsed.queryParameters['redirect_uri'] ?? '';
      if (redirectParam.isNotEmpty) {
        final r = Uri.parse(redirectParam);
        if (r.scheme.isNotEmpty) callbackScheme = r.scheme;
      }
    } catch (_) {}

    debugPrint('[SSO] detected callbackScheme=$callbackScheme');

    // Push the WebView screen and wait for the redirect result
    final result = await Navigator.of(context).push<Uri>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _SsoWebViewScreen(
          authUrl: authUrl,
          callbackScheme: callbackScheme,
        ),
      ),
    );

    if (result == null) {
      throw Exception('SSO cancelled by user');
    }

    return result;
  }

  @visibleForTesting
  Future<void> clearStoredSso() async {
    await _deleteSecure(key: _kVerifierKey);
    await _deleteSecure(key: _kStateKey);
    await _deleteSecure(key: _kTenantKey);
  }
}

// ---------------------------------------------------------------------------
// Full-screen WebView — no AppBar, no address bar
// ---------------------------------------------------------------------------

class _SsoWebViewScreen extends StatefulWidget {
  final String authUrl;
  final String callbackScheme;

  const _SsoWebViewScreen({
    required this.authUrl,
    required this.callbackScheme,
  });

  @override
  State<_SsoWebViewScreen> createState() => _SsoWebViewScreenState();
}

class _SsoWebViewScreenState extends State<_SsoWebViewScreen> {
  bool _loading = true;
  bool _didComplete = false;

  bool _isCallbackUrl(String url) =>
      url.startsWith('${widget.callbackScheme}://') ||
      url.startsWith('${widget.callbackScheme}:');

  void _handleUrl(String url) {
    if (!_isCallbackUrl(url)) return;
    if (_didComplete) return;

    debugPrint('[SSO][WebView] intercepted callback URL: $url');
    _didComplete = true;

    final uri = Uri.parse(url);
    if (mounted) Navigator.of(context).pop(uri);
  }

  void _cancel() {
    if (_didComplete) return;
    _didComplete = true;
    if (mounted) Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ← No AppBar: no address bar, completely clean UI
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.authUrl),
              ),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                javaScriptEnabled: true,
                supportZoom: false,
                clearCache: true,
                userAgent:
                    'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
                    '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
              ),
              onLoadStart: (controller, url) {
                debugPrint('[SSO][WebView] loadStart: $url');
                _handleUrl(url?.toString() ?? '');
              },
              onLoadStop: (controller, url) {
                debugPrint('[SSO][WebView] loadStop: $url');
                if (mounted) setState(() => _loading = false);
                _handleUrl(url?.toString() ?? '');
              },
              shouldOverrideUrlLoading: (controller, action) async {
                final url = action.request.url?.toString() ?? '';
                debugPrint('[SSO][WebView] shouldOverride: $url');
                if (_isCallbackUrl(url)) {
                  _handleUrl(url);
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                debugPrint('[SSO][WebView] error: ${error.description}');
                final url = request.url.toString();
                // Callback scheme errors are expected — the WebView can't
                // navigate to a custom scheme, so we treat it as success
                if (_isCallbackUrl(url)) _handleUrl(url);
              },
            ),

            // Loading spinner
            if (_loading)
              const Center(child: CircularProgressIndicator()),

            // Close / cancel button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: _cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}