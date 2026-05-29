import 'dart:convert';

import 'package:cn_pocket_hr/api/api_client.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level handler — called when app is terminated or in background.
/// Must be a top-level function (not a class method).
/// Firebase is initialized here using the native config files embedded in the
/// APK/IPA at build time (google-services.json or GoogleService-Info.plist
/// for the specific flavor that was built).
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Ensure Flutter plugin bindings are ready in this background isolate
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize only if not already initialized (safe to call multiple times)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  debugPrint('====== FCM BACKGROUND MESSAGE ======');
  debugPrint('  messageId  : ${message.messageId}');
  debugPrint('  title      : ${message.notification?.title}');
  debugPrint('  body       : ${message.notification?.body}');
  debugPrint('  data       : ${message.data}');
  debugPrint('  sentTime   : ${message.sentTime}');
  debugPrint('====================================');

  // LocalStorage (Hive) is not safe in background isolates — writes to disk
  // but the main isolate's in-memory cache never sees the update.
  // Use SharedPreferences as a buffer instead: it is isolate-safe.
  try {
    final prefs = await SharedPreferences.getInstance();
    final pending =
        prefs.getStringList('fcm_pending_notifications') ?? <String>[];
    pending.add(jsonEncode({
      'id':
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? message.data['title'] ?? '',
      'body': message.notification?.body ?? message.data['body'] ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    }));
    await prefs.setStringList('fcm_pending_notifications', pending);
    debugPrint(
        'FCMService: background notification queued (${pending.length} pending)');
  } catch (e) {
    debugPrint('FCMService: background save to SharedPrefs failed: $e');
  }
}

class FCMService {
  FCMService._();

  /// Global navigator key — set this on your [MaterialApp.navigatorKey]
  /// so FCMService can navigate without a BuildContext.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Unread notification count. Listen to this to show a badge in the UI.
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  static const String _notificationsRoute = '/HRNotifications';

  static void _navigateToNotifications() {
    navigatorKey.currentState?.pushNamed(_notificationsRoute);
  }

  /// Load (or reload) persisted unread count from storage.
  /// Call at startup and whenever the app returns to the foreground.
  static Future<void> loadUnreadCount() async {
    // First drain any notifications saved by the background isolate
    await transferPendingNotifications();
    try {
      final storage = LocalStorage('pocketHR');
      await storage.ready;
      final raw = storage.getItem('fcm_notifications');
      if (raw is List) {
        unreadCount.value =
            raw.where((e) => e is Map && e['read'] == false).length;
      } else {
        unreadCount.value = 0;
      }
    } catch (_) {}
  }

  /// Drains any notifications queued by the background isolate into LocalStorage.
  /// Safe to call multiple times; uses messageId for deduplication.
  static Future<void> transferPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList('fcm_pending_notifications');
      if (pending == null || pending.isEmpty) return;

      final storage = LocalStorage('pocketHR');
      await storage.ready;

      final List<dynamic> existing =
          List<dynamic>.from(storage.getItem('fcm_notifications') ?? []);
      final existingIds = existing
          .whereType<Map>()
          .map((e) => e['id']?.toString())
          .whereType<String>()
          .toSet();

      bool added = false;
      // pending list is oldest-first; reverse so newest ends up at index 0
      for (final item in pending.reversed) {
        try {
          final n = jsonDecode(item) as Map<String, dynamic>;
          final id = n['id']?.toString() ?? '';
          if (id.isNotEmpty && !existingIds.contains(id)) {
            existing.insert(0, n);
            existingIds.add(id);
            added = true;
          }
        } catch (_) {}
      }

      if (added) {
        await storage.setItem('fcm_notifications', existing.take(50).toList());
        debugPrint(
            'FCMService: transferred ${pending.length} pending notification(s)');
      }

      // Clear the SharedPreferences buffer regardless
      await prefs.remove('fcm_pending_notifications');
    } catch (e) {
      debugPrint('FCMService: transferPendingNotifications failed: $e');
    }
  }

  /// Call this when the user opens the notifications screen to clear the badge
  /// and mark all notifications as read in storage.
  static Future<void> resetUnreadCount() async {
    unreadCount.value = 0;
    try {
      final storage = LocalStorage('pocketHR');
      await storage.ready;
      final raw = storage.getItem('fcm_notifications');
      if (raw is List) {
        final updated = raw.map((e) {
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            m['read'] = true;
            return m;
          }
          return e;
        }).toList();
        await storage.setItem('fcm_notifications', updated);
      }
    } catch (_) {}
  }

  /// Marks a single notification as read by its [id].
  /// Updates [unreadCount] to reflect the new count.
  static Future<void> markNotificationRead(String id) async {
    try {
      final storage = LocalStorage('pocketHR');
      await storage.ready;
      final raw = storage.getItem('fcm_notifications');
      if (raw is List) {
        final updated = raw.map((e) {
          if (e is Map && e['id']?.toString() == id) {
            final m = Map<String, dynamic>.from(e);
            m['read'] = true;
            return m;
          }
          return e;
        }).toList();
        await storage.setItem('fcm_notifications', updated);
        unreadCount.value =
            updated.where((e) => e is Map && e['read'] == false).length;
      }
    } catch (e) {
      debugPrint('FCMService: markNotificationRead failed: $e');
    }
  }

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'pocket_hr_notifications',
    'PocketHR Notifications',
    description: 'Attendance and HR notifications',
    importance: Importance.high,
  );

  /// Call once at app startup, after [Firebase.initializeApp()].
  static Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

    await _initLocalNotifications();
    await _requestPermission();

    // Foreground messages — show a local notification banner
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // Tapped while app was in background — save & navigate
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      debugPrint('====== FCM NOTIFICATION TAPPED (background) ======');
      debugPrint('  messageId  : ${message.messageId}');
      debugPrint('  title      : ${message.notification?.title}');
      debugPrint('  body       : ${message.notification?.body}');
      debugPrint('  data       : ${message.data}');
      debugPrint('==================================================');
      await saveNotification(message);
      _navigateToNotifications();
    });

    // Tapped while app was terminated — save & navigate
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('====== FCM NOTIFICATION TAPPED (terminated) ======');
      debugPrint('  messageId  : ${initial.messageId}');
      debugPrint('  title      : ${initial.notification?.title}');
      debugPrint('  body       : ${initial.notification?.body}');
      debugPrint('  data       : ${initial.data}');
      debugPrint('==================================================');
      await saveNotification(initial);
      _navigateToNotifications();
    }

    // Print token at startup
    await getToken();

    // Transfer any notifications saved by the background isolate into main storage
    await transferPendingNotifications();

    // Load persisted unread count
    await loadUnreadCount();
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Foreground local notification tapped — navigate to notifications screen
        _navigateToNotifications();
      },
    );

    // Create high-importance channel for Android 8+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Android 13+ (API 33): POST_NOTIFICATIONS runtime permission
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _handleForeground(RemoteMessage message) async {
    debugPrint('====== FCM FOREGROUND MESSAGE ======');
    debugPrint('  messageId  : ${message.messageId}');
    debugPrint('  title      : ${message.notification?.title}');
    debugPrint('  body       : ${message.notification?.body}');
    debugPrint('  data       : ${message.data}');
    debugPrint('  sentTime   : ${message.sentTime}');
    debugPrint('====================================');
    await saveNotification(message);

    final n = message.notification;
    if (n == null) return;

    await _localNotifications.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Persists a notification to LocalStorage so the in-app list can display it.
  static Future<void> saveNotification(RemoteMessage message) async {
    try {
      final storage = LocalStorage('pocketHR');
      await storage.ready;

      final List<dynamic> existing =
          List<dynamic>.from(storage.getItem('fcm_notifications') ?? []);

      // Deduplication: skip if a notification with the same messageId already exists
      final notificationId =
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final alreadyExists = existing
          .whereType<Map>()
          .any((e) => e['id']?.toString() == notificationId);
      if (alreadyExists) return;

      existing.insert(0, {
        'id': notificationId,
        'title': message.notification?.title ?? message.data['title'] ?? '',
        'body': message.notification?.body ?? message.data['body'] ?? '',
        'data': message.data,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });

      // Keep at most 50 notifications
      await storage.setItem('fcm_notifications', existing.take(50).toList());

      // Increment unread badge
      unreadCount.value = unreadCount.value + 1;
    } catch (e) {
      debugPrint('FCMService: failed to save notification: $e');
    }
  }

  /// Returns the FCM device token (useful for sending targeted pushes from backend).
  static Future<String?> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('========== FCM TOKEN ==========');
      debugPrint(token ?? 'NO TOKEN');
      debugPrint('================================');
      return token;
    } catch (e) {
      debugPrint('FCMService: failed to get token: $e');
      return null;
    }
  }

  /// Registers the FCM token with the backend for the current user.
  /// Calls POST {baseUrl}/teams/{userId}/fcm-token
  static Future<void> sendTokenToBackend() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        debugPrint(
            'FCMService: no token available, skipping backend registration');
        return;
      }

      final userId = await ApiClient.getResolvedUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint(
            'FCMService: no userId available, skipping FCM token registration');
        return;
      }

      final baseUrl = FlavorConfig.instance.apiBaseUrl;
      final url = '$baseUrl/teams/$userId/fcm-token';
      debugPrint('FCMService: sending token=$token');
      final response = await ApiClient.post(url, body: {'fcm_token': token});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('FCMService: token registered successfully');
      } else {
        debugPrint(
            'FCMService: token registration failed [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      debugPrint('FCMService: sendTokenToBackend error: $e');
    }
  }
}
