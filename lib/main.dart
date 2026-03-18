import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/constants/provider/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';

final GlobalKey<NavigatorState> fcmNavigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('💀 Background Message: ${message.notification?.title}');
  print('📦 Message Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await _initializeFCMService();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const PartsAddaApp(),
    ),
  );
}

Future<void> _initializeFCMService() async {
  try {
    // Set the navigator key for FCM routing
    FCMService.navigatorKey = AppRouter.rootNavigatorKey;

    // Initialize FCM service
    final fcmService = FCMService();
    await fcmService.init();

    print('✅ FCM Service initialized successfully');
  } catch (e) {
    print('❌ FCM initialization error: $e');
  }
}
