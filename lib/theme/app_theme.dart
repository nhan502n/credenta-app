import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandOrange = Color(0xFFE75E28);
  static const Color bgDark = Color(0xFF121418);
  static const Color cardBg = Color(0xFF1C1F25);
  static const Color logoBg = Color(0xFFEDE7E1);

  static final lightTheme = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: brandOrange,
      secondary: brandOrange,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandOrange,
        side: const BorderSide(color: brandOrange, width: 1.5),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
