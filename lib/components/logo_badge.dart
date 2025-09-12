import 'package:flutter/material.dart';

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/logo.png', // Đường dẫn logo thật
          width: 120,
          height: 120,
          fit: BoxFit.contain, // Giữ tỷ lệ logo, không bị méo
        ),
      ),
    );
  }
}
