import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cn_pocket_hr/services/offline_attendance_service.dart';

class ConnectionProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityResult? _lastResult;
  ConnectivityResult? get lastResult => _lastResult;

  bool get isWifi => _lastResult == ConnectivityResult.wifi;
  bool get isMobile => _lastResult == ConnectivityResult.mobile;
  String get connectionType => _lastResult?.toString().split('.').last ?? 'none';

  // transient banner state: when true the UI should show the connection message briefly
  bool _showBanner = false;
  bool get showBanner => _showBanner;
  Timer? _bannerTimer;

  late final StreamSubscription<dynamic> _subscription;

  ConnectionProvider() {
    _init();
  }

  Future<void> _init() async {
    final connectivity = Connectivity();
    try {
      final raw = await connectivity.checkConnectivity();
      _lastResult = _toConnectivityResult(raw);
      _isOnline = await _checkInternetAccess();
      notifyListeners();
      // show banner briefly on startup so initial state is visible
      _showTransientBanner();
    } catch (_) {
      _isOnline = true;
      notifyListeners();
    }

    _subscription = connectivity.onConnectivityChanged.listen((rawResult) async {
      final oldOnline = _isOnline;
      _lastResult = _toConnectivityResult(rawResult);
      final nowOnline = await _checkInternetAccess();
      _isOnline = nowOnline;

      // debug
      try {
        print('[ConnectionProvider] raw=$rawResult normalized=$_lastResult online=$_isOnline');
      } catch (_) {}
      _showTransientBanner();
      if (!oldOnline && _isOnline) {
        try {
          OfflineAttendanceService.instance.syncPending();
        } catch (_) {}
      }

      if (oldOnline != _isOnline) notifyListeners();
    });
  }

  void _showTransientBanner({Duration duration = const Duration(seconds: 10)}) {
    try {
      _bannerTimer?.cancel();
    } catch (_) {}
    _showBanner = true;
    notifyListeners();
    _bannerTimer = Timer(duration, () {
      _showBanner = false;
      notifyListeners();
    });
  }

  ConnectivityResult _toConnectivityResult(dynamic raw) {
    try {
      final s = raw?.toString() ?? '';
      final ls = s.toLowerCase();
      if (ls.contains('wifi')) return ConnectivityResult.wifi;
      if (ls.contains('mobile') || ls.contains('cellular')) return ConnectivityResult.mobile;
      if (ls.contains('ethernet')) return ConnectivityResult.ethernet;
      if (ls.contains('vpn')) return ConnectivityResult.vpn;
      if (ls.contains('bluetooth')) return ConnectivityResult.bluetooth;
      return ConnectivityResult.none;
    } catch (_) {
      return ConnectivityResult.none;
    }
  }

  Future<bool> _checkInternetAccess({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final lookup = await InternetAddress.lookup('example.com').timeout(timeout);
      if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    try {
      _subscription.cancel();
    } catch (_) {}
    try { _bannerTimer?.cancel(); } catch (_) {}
    super.dispose();
  }
}
