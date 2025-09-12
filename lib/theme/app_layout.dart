import 'package:flutter/widgets.dart';

/// All spacing/padding used across the app
class AppLayout {
  // Page padding
  static const double padH = 40;
  static const double padV = 50;
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: padH, vertical: padV);

  // Standard spacing before CTA (large bottom button)
  static const double gapBeforeCta = 32;
  static const SizedBox gapBeforeCtaBox = SizedBox(height: gapBeforeCta);

  // Commonly used gaps
  static const SizedBox gapXS = SizedBox(height: 0);
  static const SizedBox gapSM = SizedBox(height: 6);
  static const SizedBox gapMD = SizedBox(height: 12);
  static const SizedBox gapLG = SizedBox(height: 16);

  /// 🔹 Function to calculate unified input field height across the app
  static double fieldHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final candidate = w * 0.1; // 10% width
    return candidate.clamp(40.0, 48.0);
  }
}
