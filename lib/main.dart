import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // để tắt debug paints
import 'package:frontend/pages/phone_verify_page.dart';
import 'theme/app_theme.dart';
import 'pages/landing_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';

void main() {
  // TẮT mọi debug paint / baseline / pointer / repaint rainbow
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintPointersEnabled = false;
  debugRepaintRainbowEnabled = false;

  runApp(const CredentaApp());
}

class CredentaApp extends StatelessWidget {
  const CredentaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credenta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/signup': (_) => const SignupPage(),
        '/login': (_) => const LoginPage(),
        '/verify-phone': (_) => const PhoneVerifyPage(),
      },
    );
  }
}
