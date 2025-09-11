import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/logo.png', // Đường dẫn logo thật
          width: 88,
          height: 88,
          fit: BoxFit.contain, // Giữ tỷ lệ logo, không bị méo
        ),
      ),
    );
  }
}
