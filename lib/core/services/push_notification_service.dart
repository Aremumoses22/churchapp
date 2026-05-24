import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background message handler — must be a top-level function
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // No UI interaction here — Firebase handles showing the notification
  // when the app is in the background/terminated.
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

// ─────────────────────────────────────────────────────────────────────────────
// PushNotificationService
//
// Responsibilities:
//   1. Initialize Firebase Messaging
//   2. Request permissions (iOS / Android 13+)
//   3. Get FCM token → register it with the backend
//   4. Show local notification banner when app is in foreground
//   5. Provide a stream for notification taps → GoRouter deep linking
// ─────────────────────────────────────────────────────────────────────────────
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _localNotifs = FlutterLocalNotificationsPlugin();
  final _userRepo = UserRepository();

  // Exposes tapped notification data so the router can navigate
  RemoteMessage? _initialMessage;
  RemoteMessage? get initialMessage => _initialMessage;

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Church App Notifications',
    description: 'All push notifications for the Church App',
    importance: Importance.high,
    playSound: true,
  );

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // 2. Request permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Push notifications denied by user');
      return;
    }

    // 3. Set up local notification plugin for foreground display
    await _initLocalNotifications();

    // 4. Register FCM token with backend
    await _registerToken();

    // 5. Refresh token when it rotates
    _fcm.onTokenRefresh.listen(_onTokenRefresh);

    // 6. Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 7. Message tapped from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // 8. Message that launched the app from terminated state
    _initialMessage = await _fcm.getInitialMessage();
  }

  /// Call this immediately after a successful login so the fresh token is
  /// registered while the session is active.
  Future<void> onLoggedIn() => _registerToken();

  // ── Deep-link helper used by GoRouter ─────────────────────────────────────

  /// Returns the deep-link path from a notification payload, or null.
  String? extractDeepLink(RemoteMessage? message) {
    if (message == null) return null;
    final data = message.data;
    final deepLink = data['deepLink'] as String?;
    if (deepLink != null && deepLink.contains('://')) {
      // Strip the scheme and use the path as a Go Router location
      return '/${deepLink.split('://').last}';
    }
    return _fallbackRoute(data['entityType'] as String?, data['entityId'] as String?);
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    // Create Android notification channel
    final androidPlugin = _localNotifs
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false, // already requested via FCM
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // User tapped a foreground local notification — handled by GoRouter
        debugPrint('[FCM] Local notification tapped: ${details.payload}');
      },
    );

    // iOS foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken() async {
    try {
      // Only register if user is logged in
      if (!AuthService.instance.isLoggedIn) return;

      final token = Platform.isIOS
          ? await _fcm.getAPNSToken().timeout(
              const Duration(seconds: 5),
              onTimeout: () => null,
            ).then((_) => _fcm.getToken())
          : await _fcm.getToken();

      if (token == null) return;

      await _userRepo.registerFcmToken(token);
      debugPrint('[FCM] Token registered: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    try {
      if (!AuthService.instance.isLoggedIn) return;
      await _userRepo.registerFcmToken(token);
      debugPrint('[FCM] Token refreshed and re-registered');
    } catch (e) {
      debugPrint('[FCM] Token refresh registration failed: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    debugPrint('[FCM] Foreground: ${notification.title}');

    // Show a local notification so the user sees it even while in the app
    _localNotifs.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['deepLink'],
    );
  }

  void _onNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped (background): ${message.notification?.title}');
    // Store as initial message so the router can handle navigation
    _initialMessage = message;
  }

  String? _fallbackRoute(String? entityType, String? entityId) {
    if (entityType == null) return null;
    switch (entityType) {
      case 'sermon':
        return entityId != null ? '/sermons/$entityId' : '/sermons';
      case 'event':
        return entityId != null ? '/events/$entityId' : '/events';
      case 'live':
        return '/live';
      case 'announcement':
        return '/home';
      case 'prayer':
        return '/prayer-requests';
      case 'group':
        return entityId != null ? '/connect-groups/$entityId' : '/connect-groups';
      case 'volunteer':
        return '/volunteer';
      default:
        return '/notifications';
    }
  }
}
