import 'package:flutter/material.dart';

/// Màu dùng chung toàn app
class AppColors {
  // Nền
  static const Color bg = Color(0xFF121418);

  // Brand
  static const Color brandOrange = Color(0xFFE75E28);
  static const Color brandCream  = Color(0xFFECDFCC);

  // Input
  static const Color inputFill50 = Color(0x80969A94); // #969A94 50%
  static const Color placeholder = Color(0xFFB3B3B3);
  static const double inputRadius = 4;

  // Icon/controls
  static const Color backCircle = Color(0xFF3C3D37);
  static const Color clearX     = Color(0xFFD0C5B4);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color title       = brandCream;

  // Checkbox
  static const Color checkboxFillChecked = brandCream;   // nền khi tick
  static const Color checkboxTick        = brandOrange;  // màu tick
  static const Color checkboxBorder      = brandOrange;

  // CTA button
  static const Color ctaFg = Colors.white;
  static const Color ctaBg = brandOrange;
  static Color ctaBgHover   = brandOrange.withOpacity(0.85);
  static Color ctaBgPressed = brandOrange.withOpacity(0.65);
}
