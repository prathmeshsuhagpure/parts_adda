import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Global navigator key for routing (pass this from main.dart)
  static GlobalKey<NavigatorState>? navigatorKey;

  // ─── Initialize FCM ───────────────────────────────────────
  Future<void> init() async {
    try {
      await _initLocalNotifications();
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ FCM: Notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ FCM: Provisional permission granted');
      } else {
        print('❌ FCM: Notification permission denied');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message (app terminated)
      await _handleInitialMessage();
    } catch (e) {
      print('❌ FCM initialization error: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        // handle tap on notification (foreground case)
        print("🔘 Notification clicked");
      },
    );

    // ✅ CREATE CHANNEL (MUST MATCH BACKEND)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // ─── Handle Foreground Messages ────────────────────────────
  /// Called when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification with custom handling
    _showForegroundNotification(message);
  }

  // ─── Handle Message Opened (Background Tap) ─────────────────
  /// Called when user taps notification while app is in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📲 Message opened from background');
    _routeToNotificationScreen(message);
  }

  // ─── Handle Initial Message (Terminated App) ──────────────────
  /// Called when app is opened via notification (terminated state)
  Future<void> _handleInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();

      if (message != null) {
        print('🚀 App opened from terminated state via notification');
        // Give app time to initialize before routing
        Future.delayed(const Duration(seconds: 1), () {
          _routeToNotificationScreen(message);
        });
      }
    } catch (e) {
      print('❌ Error handling initial message: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? "No Title",
      body: message.notification?.body ?? "No Body",
      notificationDetails: notificationDetails,
      payload: message.data.toString(),
    );
  }

  // ─── Route to Appropriate Screen ───────────────────────────
  void _routeToNotificationScreen(RemoteMessage message) {
    if (navigatorKey?.currentContext == null) {
      return;
    }

    final context = navigatorKey!.currentContext!;
    final notificationType = message.data['type'] ?? 'general';
    final actionId = message.data['actionId'];

    print('🎯 Routing to: $notificationType (actionId: $actionId)');

    // Route based on notification type
    switch (notificationType) {
      case 'order':
      case 'delivery':
      case 'payment':
      case 'newOrder':
        if (actionId != null) {
          context.push('/orders/$actionId');
        } else {
          context.push('/orders');
        }
        break;

      case 'review':
        context.push('/reviews');
        break;

      case 'promo':
      case 'offer':
        context.push('/offers');
        break;

      case 'lowStock':
      case 'inventory':
        context.push('/inventory');
        break;

      case 'payout':
        context.push('/payments');
        break;

      default:
        context.push('/notifications');
    }
  }
}
