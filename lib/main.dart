import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // để tắt debug paints
import 'package:frontend/pages/document/document_types_page.dart';
import 'package:frontend/pages/login/phone_verify_page.dart';
import 'theme/app_theme.dart';
import 'pages/home/landing_page.dart';
import 'pages/home/landing_page_fake.dart';
import 'pages/signup/signup_page.dart';
import 'pages/login/login_page.dart';
import 'pages/document/my_documents_page.dart';

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
        '/2': (_) => const LandingPageFake(),
        '/signup': (_) => const SignupPage(),
        '/login': (_) => const LoginPage(),
        '/verify-phone': (_) => const PhoneVerifyPage(),
        '/my-documents': (_) => const MyDocumentsPage(),
        DocumentTypesPage.route: (_) => const DocumentTypesPage(),
        
      },
    );
  }
}
