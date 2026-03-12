import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/constants/provider/theme_provider.dart';

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
    ),
  );

  // Firebase
  //await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const PartsAddaApp(),
    ),
  );
}
