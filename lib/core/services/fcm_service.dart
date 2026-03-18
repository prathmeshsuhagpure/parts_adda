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

      // Get FCM token
      final token = await _messaging.getToken();
      print('📱 FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message (app terminated)
      await _handleInitialMessage();

      print('✅ FCM Service initialized successfully');
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
    print('🔔 Foreground Message Received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // Parse notification data
    final notificationData = _parseNotificationData(message);
    print('Data: $notificationData');

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

  // ─── Parse Notification Data ──────────────────────────────
  Map<String, dynamic> _parseNotificationData(RemoteMessage message) {
    return {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'imageUrl':
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      'data': message.data,
      'messageId': message.messageId,
      'sentTime': message.sentTime,
    };
  }

  void _showForegroundNotification(RemoteMessage message) async {
    print('📬 Showing foreground notification: ${message.notification?.title}');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          importance: Importance.max,
          priority: Priority.high,
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
      print('⚠️ Navigator context not available');
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
