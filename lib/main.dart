import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/aira_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for a calm experience
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AiraTheme.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  runApp(const AiraApp());
}

/// Aira - A Gentle Emotional Support Companion
/// 
/// Aira exists for moments when someone wants:
/// - To feel heard
/// - To slow down mentally
/// - To express emotions safely
/// - To not feel alone with their thoughts
class AiraApp extends StatelessWidget {
  const AiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aira',
      debugShowCheckedModeBanner: false,
      theme: AiraTheme.lightTheme,
      darkTheme: AiraTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light for calm experience
      home: const SplashScreen(),
    );
  }
}
