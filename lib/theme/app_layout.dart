import 'package:flutter/widgets.dart';

/// Tất cả khoảng cách/padding dùng chung cho toàn app
class AppLayout {
  // Padding trang
  static const double padH = 40;
  static const double padV = 50;
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: padH, vertical: padV);

  // Khoảng cách chuẩn trước CTA (nút lớn cuối trang)
  static const double gapBeforeCta = 32;
  static const SizedBox gapBeforeCtaBox = SizedBox(height: gapBeforeCta);

  // Một số khoảng cách hay dùng
  static const SizedBox gapXS = SizedBox(height: 2);
  static const SizedBox gapSM = SizedBox(height: 6);
  static const SizedBox gapMD = SizedBox(height: 12);
  static const SizedBox gapLG = SizedBox(height: 16);
}
