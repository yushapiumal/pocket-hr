import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/services/offline_attendance_service.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/constants/slideanimation.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/screens/qr/qr_scanner_page.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/controllers/controller.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/glass_box.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/custom_blur_hash.dart';
import 'package:cn_pocket_hr/models/slider_model.dart';
import 'package:cn_pocket_hr/models/hr/check_in_check_out_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:cn_pocket_hr/providers/connection_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:audioplayers/audioplayers.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  _MobileHomeState createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> with TickerProviderStateMixin {
  int currentIndex = 0;
  AnimationController? _animationController;
  PageController? _controller;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AudioPlayer _audioPlayer;

  String morningBg =
      "https://www.farmersalmanac.com/wp-content/uploads/2020/11/Earliest-Sunrise-June-A191879830.jpg";

  String afternoonBg =
      "https://www.farmersalmanac.com/wp-content/uploads/2020/11/Earliest-Sunrise-June-A191879830.jpg";

  String eveningBg =
      "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/sunset-quotes-21-1586531574.jpg";

  String nightBg = "https://wallpaperaccess.com/full/2113857.jpg";

  late String bgImg;
  String? _dateTime;
  late Timer _timer;
  late String checking = "CHECK-IN";
  final DateTime now = DateTime.now();
  LocalStorage storage = LocalStorage('pocketHR');
  APIService apiService = APIService();
  HRController controller = HRController();
  bool _pressingCheckIn = false;
  bool _pressingCheckOut = false;
  bool _withinQrRadius =
      false; // true when last scanned QR was within allowed radius
  bool _isRemotePunch = false; // true when punch triggered via remote button

  // --- QR gating window (10s) ---
  Timer? _qrWindowTimer;
  DateTime? _qrWindowEnd;
  int _qrSecondsLeft = 0;
  bool _qrBusy = false;

  // Blink animation while QR window is active
  AnimationController? _blinkController;

  // Top toast overlay
  void showTopToast(String message,
      {Color? background,
      Duration duration = const Duration(seconds: 3),
      VoidCallback? onTap}) {
    final overlay = Overlay.of(context);

    final animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    final animation =
        CurvedAnimation(parent: animController, curve: Curves.easeOut);

    late OverlayEntry entry;
    entry = OverlayEntry(builder: (ctx) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 12,
        right: 12,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(animation),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                try {
                  animController.reverse();
                } catch (_) {}
                try {
                  entry.remove();
                } catch (_) {}
                try {
                  animController.dispose();
                } catch (_) {}
                if (onTap != null) onTap();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: background ?? const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(message,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    overlay.insert(entry);
    animController.forward();

    Future.delayed(duration, () async {
      try {
        await animController.reverse();
      } catch (_) {}
      try {
        entry.remove();
      } catch (_) {}
      try {
        animController.dispose();
      } catch (_) {}
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    getLocation();
    // changeBTN();
    _controller = PageController(initialPage: 0);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // audio player for countdown sound
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    try {
      _qrWindowTimer?.cancel();
    } catch (_) {}
    try {
      _blinkController?.dispose();
    } catch (_) {}
    try {
      _audioPlayer.stop();
      _audioPlayer.dispose();
    } catch (_) {}
    _timer.cancel();
    streamSubscription.cancel();
    _animationController!.dispose();
    super.dispose();
  }

  getTime() {
    String languageCode = Localizations.localeOf(context).languageCode;
    String formattedDateTime = "";
    String suffix = 'th';
    final int digit = now.day % 10;
    if ((digit > 0 && digit < 4) && (now.day < 11 || now.day > 13)) {
      suffix = <String>['st', 'nd', 'rd'][digit - 1];
    }

    if (languageCode == 'si' || languageCode == 'ta') {
      formattedDateTime = DateFormat("dd MMM yyyy - kk:mm:ss", languageCode)
          .format(DateTime.now())
          .toString();
    } else {
      formattedDateTime =
          DateFormat("d'$suffix' MMM yyyy - kk:mm:ss", languageCode)
              .format(DateTime.now())
              .toString();
    }

    setState(() {
      _dateTime = formattedDateTime;
    });
  }

  checkinCheckout(type, {bool isRemote = false}) async {
    DateTime getCurrentTimestamp = DateTime.now();
    String date = controller.formatISOTime(getCurrentTimestamp);
    final latStr = (latitude != null) ? latitude.toString() : null;
    final lngStr = (longitude != null) ? longitude.toString() : null;
    final addr = (address != null) ? address.toString() : null;

    // If offline, save immediately and avoid calling remote API (prevents socket errors)
    final conn = Provider.of<ConnectionProvider>(context, listen: false);
    if (!conn.isOnline) {
      try {
        final model = AttendancePunchModel(
          attendanceId: DateTime.now().millisecondsSinceEpoch.toString(),
          uid: storage.getItem('uid')?.toString() ?? 'local',
          type: type,
          time: date,
          lat: (latitude is double)
              ? latitude
              : double.tryParse(latitude?.toString() ?? '') ?? 0.0,
          lng: (longitude is double)
              ? longitude
              : double.tryParse(longitude?.toString() ?? '') ?? 0.0,
          address: address ?? '',
          deviceId: '',
          deviceModel: '',
          deviceBrand: '',
          devicePlatform: '',
          deviceVersion: '',
          deviceIdentifier: '',
          deviceIp: '',
          batteryLevel: 0,
          tenant: storage.getItem('company') ?? '',
        );
        await OfflineAttendanceService.instance.insertPunch(model);
        if (mounted)
          showTopToast('Saved locally, will sync when online',
              background: Colors.orange);
      } catch (e) {
        if (mounted)
          showTopToast('Failed to save locally', background: Colors.red);
      }
      return;
    }

    // Remote path: attempt API call
    Map? res;
    try {
      res = await apiService.checkInCheckout(
        date,
        type,
        latitude: latStr,
        longitude: lngStr,
        address: addr,
        isRemotePunch: isRemote,
      );
    } catch (_) {
      // network error: save offline instead of logging error
      try {
        final model = AttendancePunchModel(
          attendanceId: DateTime.now().millisecondsSinceEpoch.toString(),
          uid: storage.getItem('uid')?.toString() ?? 'local',
          type: type,
          time: date,
          lat: (latitude is double)
              ? latitude
              : double.tryParse(latitude?.toString() ?? '') ?? 0.0,
          lng: (longitude is double)
              ? longitude
              : double.tryParse(longitude?.toString() ?? '') ?? 0.0,
          address: address ?? '',
          deviceId: '',
          deviceModel: '',
          deviceBrand: '',
          devicePlatform: '',
          deviceVersion: '',
          deviceIdentifier: '',
          deviceIp: '',
          batteryLevel: 0,
          tenant: storage.getItem('company') ?? '',
        );
        await OfflineAttendanceService.instance.insertPunch(model);
        if (mounted)
          showTopToast('Saved locally, will sync when online',
              background: Colors.orange);
      } catch (e) {
        if (mounted)
          showTopToast('Failed to save locally', background: Colors.red);
      }
      return;
    }

    // Remote succeeded: show response message
    // show API response
    String msg = '';
    Color bg = Colors.black;

    if (res is Map && res.containsKey('status')) {
      final statusCode = res['status'];
      if (statusCode == 200) {
        msg = type == 'checkout'
            ? AppLocalizations.of(context)!.checkOutSuccess
            : AppLocalizations.of(context)!.checkInSuccess;
        bg = type == 'checkout' ? HRColors.orangeColor : HRColors.blueColor;
      } else if (statusCode == 400) {
        msg = AppLocalizations.of(context)!.cantLocate;
        bg = Colors.red;
      } else if (statusCode == 401 || statusCode == 403) {
        msg = AppLocalizations.of(context)!.sessionExpired;
        bg = Colors.red;
      } else {
        msg = AppLocalizations.of(context)!.filedToPerform;
        bg = Colors.red;
      }
    } else {
      msg = AppLocalizations.of(context)!.filedToPerform;
      bg = Colors.red;
    }

    if (mounted) showTopToast(msg, background: bg);
  }

  changeBTN() {
    if (storage.getItem('checking')) {
      checking = "CHECK-OUT";
    } else {
      checking = "CHECK-IN";
    }
  }

  setBgImage() {
    var hours = DateTime.now().hour;
    if (hours < 12) {
      bgImg = morningBg;
    } else if (hours < 14) {
      bgImg = afternoonBg;
    } else if (hours < 18) {
      bgImg = eveningBg;
    } else {
      bgImg = nightBg;
    }
    return bgImg;
  }

  var latitude;
  var longitude;
  var address;
  late StreamSubscription<Position> streamSubscription;

  getLocation() async {
    bool serviceEnabled;

    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      latitude = position.latitude;
      longitude = position.longitude;
      getAddressFromLatLang(position);
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];

    address = '${place.street}, ${place.locality}';
  }

  // Compute distance between two lat/lng points in meters (Haversine formula)
  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * (math.pi / 180.0);
    final phi2 = lat2 * (math.pi / 180.0);
    final dPhi = (lat2 - lat1) * (math.pi / 180.0);
    final dLambda = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  Future<bool> _ensureQrValidatedIfRequired() async {
    if (!apiService.qrEnable) {
      _withinQrRadius = true;
      return true;
    }

    if (_qrWindowActive && _withinQrRadius) return true;

    // Fetch location config to decide whether QR is enabled.
    final userId = storage.getItem('uid')?.toString() ?? '';
    final locations = await apiService.getTenantCoordinateFromQr(userId);

    while (true) {
      final usernameForQr = (storage.getItem('name') ??
              storage.getItem('username') ??
              storage.getItem('userName') ??
              '')
          .toString();
      final bool isRemoteAllowed = apiService.remoteEnable;

      final qr = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => QrScannerPage(
            username: usernameForQr,
            showRemoteButton: isRemoteAllowed,
            onRemotePressed: () {
              Navigator.of(context).pop('remote');
            },
            validator: (raw) {
              double? qlat;
              double? qlng;
              try {
                String normalized = raw.trim();
                if (normalized.contains("'") && !normalized.contains('"')) {
                  normalized = normalized.replaceAll("'", '"');
                }
                final parsed = jsonDecode(normalized);
                if (parsed is Map) {
                  final latAny = parsed['lat'] ?? parsed['latitude'];
                  final lngAny = parsed['lng'] ?? parsed['longitude'];
                  if (latAny != null && lngAny != null) {
                    qlat = latAny is num
                        ? latAny.toDouble()
                        : double.tryParse(latAny.toString());
                    qlng = lngAny is num
                        ? lngAny.toDouble()
                        : double.tryParse(lngAny.toString());
                  }
                }
              } catch (_) {}

              if (qlat == null || qlng == null) {
                return AppLocalizations.of(context)!.qrNoCoordinates;
              }

              // Exact match check across array of allowed locations
              dynamic matchedLocation;
              for (var loc in locations) {
                // Determine raw values as safely parsed doubles by bypassing nested types
                dynamic rawLat;
                dynamic rawLng;
                try {
                  rawLat = loc.lat;
                  rawLng = loc.lng;
                } catch (_) {}

                double currentLat = 0.0;
                double currentLng = 0.0;
                if (rawLat is num) {
                  currentLat = rawLat.toDouble();
                } else if (rawLat != null) {
                  currentLat = double.tryParse(rawLat.toString()) ?? 0.0;
                }

                if (rawLng is num) {
                  currentLng = rawLng.toDouble();
                } else if (rawLng != null) {
                  currentLng = double.tryParse(rawLng.toString()) ?? 0.0;
                }

                if (qlat == currentLat && qlng == currentLng) {
                  matchedLocation = loc;
                  break;
                }
              }

              if (matchedLocation == null) {
                return AppLocalizations.of(context)!
                    .qrCoordinatesMismatchMessage;
              }

              // Get radius specifically for the matched location
              double allowedRadiusMeters = 500.0;
              try {
                final dynamic anyLoc = matchedLocation;
                dynamic r;
                try {
                  r = anyLoc.radius ?? anyLoc.radiusMeters ?? anyLoc.range;
                } catch (_) {}
                if (r is num) {
                  allowedRadiusMeters = r.toDouble();
                } else if (r is String) {
                  allowedRadiusMeters = double.tryParse(r) ?? 500.0;
                }
              } catch (_) {}

              // After scan: validate device location within allowed radius
              final double? dlat = (latitude is num)
                  ? (latitude as num).toDouble()
                  : double.tryParse(latitude?.toString() ?? '');

              // final double? dlat = 6.927079;
              // final double? dlng = 79.861244;

              final double? dlng = (longitude is num)
                  ? (longitude as num).toDouble()
                  : double.tryParse(longitude?.toString() ?? '');

              if (dlat == null || dlng == null) {
                return 'Location not available';
              }
              final deviceDist = _distanceBetween(dlat, dlng, qlat, qlng);
              if (deviceDist > allowedRadiusMeters) {
                final username = (storage.getItem('name') ??
                        storage.getItem('username') ??
                        '')
                    .toString();
                final baseMsg = AppLocalizations.of(context)!.qrCannotPunchHere(
                  username.isNotEmpty ? username : 'User',
                );
                final extra =
                    ' (Distance: ${deviceDist.toStringAsFixed(0)}m, Allowed: ${allowedRadiusMeters.toStringAsFixed(0)}m)';
                return baseMsg + extra;
              }

              return null; // accept
            },
          ),
        ),
      );

      // user cancelled or scan was successful
      if (qr == null || qr.trim().isEmpty) return false;

      // check if it's the remote button override
      if (qr == 'remote') {
        _withinQrRadius = true;
        _isRemotePunch = true;
        _startQrWindow(20);
        showTopToast(AppLocalizations.of(context)!.activeRemoteCheking,
            background: Colors.green);
        return true;
      }

      // accepted by validator; start countdown
      _isRemotePunch = false;
      _withinQrRadius = true;
      _startQrWindow(20);
      showTopToast(AppLocalizations.of(context)!.qrValidatedTapToPunch,
          background: Colors.green);
      return true;
    }
  }

  bool get _qrWindowActive {
    if (_qrWindowEnd == null) return false;
    return DateTime.now().isBefore(_qrWindowEnd!);
  }

  void _startQrWindow(int seconds) {
    _qrWindowTimer?.cancel();
    _qrWindowEnd = DateTime.now().add(Duration(seconds: seconds));
    _qrSecondsLeft = seconds;
    _qrWindowTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final end = _qrWindowEnd;
      if (end == null) {
        t.cancel();
        return;
      }
      final left = end.difference(DateTime.now()).inSeconds;
      if (left <= 0) {
        _qrSecondsLeft = 0;
        _withinQrRadius = false;
        _qrWindowEnd = null;
        t.cancel();

        // stop blinking
        try {
          _blinkController?.stop();
          _blinkController?.value = 1.0;
        } catch (_) {}
        // stop audio playback when window ends
        try {
          _audioPlayer.stop();
        } catch (_) {}
      } else {
        _qrSecondsLeft = left;
      }
      if (mounted) setState(() {});
    });

    // start blinking (full container) while timer is active
    try {
      _blinkController?.reset();
      _blinkController?.repeat(reverse: true);
    } catch (_) {}
    // start looping countdown audio (asset path: assets/sounds/countdown.mp3)
    try {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.play(AssetSource('sounds/clock.wav'));
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _onCheckTap(String type) async {
    if (_qrBusy) return;
    _qrBusy = true;
    try {
      // If already validated and inside countdown window => punch now.
      if (_qrWindowActive && _withinQrRadius) {
        await checkinCheckout(type, isRemote: _isRemotePunch);
        _qrWindowTimer?.cancel();
        _qrWindowEnd = null;
        _qrSecondsLeft = 0;
        _withinQrRadius = false;
        _isRemotePunch = false;

        // stop blinking immediately after punch
        try {
          _blinkController?.stop();
          _blinkController?.value = 1.0;
        } catch (_) {}
        // stop audio when punch occurs
        try {
          _audioPlayer.stop();
        } catch (_) {}
        return;
      }

      // No active window => run validation.
      final ok = await _ensureQrValidatedIfRequired();
      if (!ok) return;
      if (!_qrWindowActive) {
        await checkinCheckout(type, isRemote: _isRemotePunch);
        _isRemotePunch = false;
        return;
      }
    } finally {
      _qrBusy = false;
      if (mounted) setState(() {});
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _getWelcomeName() {
    // Try flat keys first
    final flat = (storage.getItem('name') ??
            storage.getItem('username') ??
            storage.getItem('userName') ??
            '')
        .toString()
        .trim();
    if (flat.isNotEmpty) return flat.split(' ').first;

    // Fall back to me_profile JSON
    try {
      final raw = storage.getItem('me_profile');
      if (raw != null) {
        final map = raw is Map ? Map<String, dynamic>.from(raw) : null;
        if (map != null) {
          final dataAny = map['data'] ?? map['result'] ?? map['user'] ?? map;
          if (dataAny is Map) {
            final data = Map<String, dynamic>.from(dataAny);

            // Try flat fields first
            final fn = (data['first_name'] ?? data['name'] ?? data['full_name'] ?? '').toString().trim();
            if (fn.isNotEmpty) return fn.split(' ').first;

            // Parse customfields array: [{"input_name":"cf_first_name","input_value":"..."}]
            final cf = data['customfields'];
            if (cf is List) {
              for (final item in cf) {
                if (item is Map) {
                  final inputName = item['input_name']?.toString() ?? '';
                  final inputValue = item['input_value']?.toString().trim() ?? '';
                  if (inputName == 'cf_first_name' && inputValue.isNotEmpty) {
                    return inputValue.split(' ').first;
                  }
                }
              }
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  Widget _buildWelcomeText() {
    final firstName = _getWelcomeName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
        if (firstName.isNotEmpty)
          Text(
            firstName,
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
            ),
          ),
      ],
    );
  }

  Widget slider() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: 1,
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, i) {
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    child: OctoImage(
                      image: CachedNetworkImageProvider(setBgImage()),
                      placeholderBuilder: OctoBlurHashFix.placeHolder(
                        sliderList[i].blurUrl!,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      errorBuilder: OctoError.icon(color: HRColors.black),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {},
              );
            },
          ),

          // Welcome text overlay — below the AppBar/drawer icon area
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 20,
            right: 20,
            child: _buildWelcomeText(),
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              top: MediaQuery.of(context).size.height * .318,
            ),
            child: SlideAnimation(
              position: 4,
              itemCount: 8,
              slideDirection: SlideDirection.fromTop,
              animationController: _animationController,
              child: GlassBox(
                redius: 40.0,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 5.2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: AnimatedBuilder(
                            animation:
                                _blinkController ?? kAlwaysDismissedAnimation,
                            builder: (context, child) {
                              final t = (_blinkController?.value ?? 0.0);
                              final blinkOpacity = 1.0 - (t * 0.65);
                              final opacity =
                                  _qrWindowActive ? blinkOpacity : 1.0;
                              return Opacity(opacity: opacity, child: child);
                            },
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      _dateTime ?? "loading...",
                                      style: TextStyle(
                                        color: HRColors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: 20.0,
                                          top: 1.0,
                                        ),
                                        child: Text(
                                          address ?? "loading...",
                                          style: TextStyle(
                                            color: HRColors.black,
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _pressingCheckIn = true),
                                    onTapUp: (_) async {
                                      setState(() => _pressingCheckIn = false);
                                      await _onCheckTap('checkin');
                                    },
                                    onTapCancel: () => setState(
                                        () => _pressingCheckIn = false),
                                    child: AnimatedScale(
                                      scale: _pressingCheckIn ? 0.96 : 1.0,
                                      duration:
                                          const Duration(milliseconds: 120),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 160),
                                        curve: Curves.easeOut,
                                        height: 50,
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              HRColors.blueColor,
                                              HRColors.blueColor,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: _pressingCheckIn
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 6),
                                                  )
                                                ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .checkIn,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            // Show countdown instead of icon while window is active
                                            if (_qrWindowActive)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.55),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  '$_qrSecondsLeft',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              )
                                            else
                                              Icon(Icons.input,
                                                  color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTapDown: (_) => setState(
                                        () => _pressingCheckOut = true),
                                    onTapUp: (_) async {
                                      setState(() => _pressingCheckOut = false);
                                      await _onCheckTap('checkout');
                                    },
                                    onTapCancel: () => setState(
                                        () => _pressingCheckOut = false),
                                    child: AnimatedScale(
                                      scale: _pressingCheckOut ? 0.96 : 1.0,
                                      duration:
                                          const Duration(milliseconds: 120),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 160),
                                        curve: Curves.easeOut,
                                        height: 50,
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              HRColors.orangeColor,
                                              HRColors.orangeColor,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: _pressingCheckOut
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 6),
                                                  )
                                                ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .checkOut,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            if (_qrWindowActive)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.55),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  '$_qrSecondsLeft',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              )
                                            else
                                              Icon(Icons.output,
                                                  color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget data() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          snap: false,
          pinned: true,
          floating: false,
          flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "",
                style:
                    TextStyle(color: HRColors.white, fontSize: 0), //TextStyle
              ), //Text
              background: Stack(children: [
                slider(),
              ])),
          actions: <Widget>[
            // Manual sync button
            GestureDetector(
              onTap: () async {
                try {
                  final count =
                      await OfflineAttendanceService.instance.syncPending();
                  showTopToast('Synced $count records',
                      background: Colors.green);
                } catch (e) {
                  showTopToast('Sync failed', background: Colors.red);
                }
              },
              child: Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.center,
                child: GlassBox(
                  redius: 40.0,
                  width: 50,
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.sync, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, HRNotifications.routeName);
              },
              child: Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.center,
                child: GlassBox(
                  redius: 40.0,
                  width: 50,
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:
                          SvgPicture.asset("assets/svg/notifications_icon.svg"),
                    ),
                  ),
                ),
              ),
            ), //IconButton//IconButton
          ], //FlexibleSpaceBar
          expandedHeight: MediaQuery.of(context).size.height / 2,
          backgroundColor: Colors.transparent.withOpacity(0.02),
          shadowColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              padding: EdgeInsets.all(5.0),
              alignment: Alignment.center,
              child: GlassBox(
                redius: 40.0,
                width: 50,
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SvgPicture.asset("assets/svg/drawer_icon.svg"),
                  ),
                ),
              ),
            ),
          ),
        ),
        //SliverAppBar
        SliverList(
          delegate: SliverChildListDelegate(
            [
              SlideAnimation(
                position: 4,
                itemCount: 8,
                slideDirection: SlideDirection.fromBottom,
                animationController: _animationController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: apiService.qrEnable ? Colors.green : Colors.red,
                    //         ),
                    //         onPressed: () {
                    //           setState(() {
                    //             apiService.qrEnable = !apiService.qrEnable;
                    //           });
                    //         },
                    //         child: Text('QR: ${apiService.qrEnable ? "ON" : "OFF"}', style: TextStyle(color: Colors.white)),
                    //       ),
                    //       const SizedBox(width: 10),
                    //       ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: apiService.remoteEnable ? Colors.green : Colors.red,
                    //         ),
                    //         onPressed: () {
                    //           setState(() {
                    //             apiService.remoteEnable = !apiService.remoteEnable;
                    //           });
                    //         },
                    //         child: Text('Remote: ${apiService.remoteEnable ? "ON" : "OFF"}', style: TextStyle(color: Colors.white)),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: 10, start: 10, end: 10),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  AppLocalizations.of(context)!.rosterText,
                                  style: TextStyle(
                                      color: HRColors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              Spacer(), // Defaults to a flex of one.
                            ]),
                            roster()
                          ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ], //<Widget>[]
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        backgroundColor: Colors.white,
        drawerScrimColor: Colors.transparent,
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: DesignConfig.drawerContent(_scaffoldKey, context),
        ),
        body: Container(
          width: double.infinity,
          child: data(),
        ),
      ),
    );
  }

  Future<void> navigationPage() async {
    Navigator.pop(context);
  }

  Widget roster() {
    final CalendarController _controller = CalendarController();

    const Color _surface = Color.fromARGB(255, 248, 250, 252);

    return GestureDetector(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              color: _surface,
              child: SfCalendar(
                view: CalendarView.month,
                controller: _controller,
                viewNavigationMode: ViewNavigationMode.none,
                dataSource: MeetingDataSource(_getDataSource()),
                headerStyle: const CalendarHeaderStyle(
                    backgroundColor: _surface, textAlign: TextAlign.center),
                monthViewSettings: MonthViewSettings(
                  showTrailingAndLeadingDates: false,
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  dayFormat: 'EEE',
                  agendaViewHeight: MediaQuery.of(context).size.height / 580,
                  showAgenda: true,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.40))
          ],
        ),
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
