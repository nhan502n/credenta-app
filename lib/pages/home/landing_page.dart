import 'package:flutter/material.dart';
import '../../components/logo_badge.dart';
import '../../theme/app_layout.dart';
import '../../theme/app_colors.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 380;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppLayout.pagePadding, // ✅ cùng padding với Login/Signup
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top
              const SizedBox(height: 16), // giống tinh thần Login
              Text(
                'Begin the process of issuing verifiable credentials to users.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: isNarrow ? 14 : 15,
                  height: 1.35,
                  decoration: TextDecoration.none,
                ),
              ),

              // Nội dung giữa
              const SizedBox(height: 48),
              const LogoBadge(),
              AppLayout.gapMD,
              Text(
                'Credenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFECDFCC),
                  fontSize: isNarrow ? 28 : 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  decoration: TextDecoration.none,
                ),
              ),
              AppLayout.gapXS,
              const Text(
                'Reusable digital identity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDCCEBF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),

              // Đẩy nút xuống đáy nhưng KHÔNG dùng Spacer to -> dùng Expanded rỗng
              const Expanded(child: SizedBox()),

              // Khoảng cách trước CTA: dùng chung với Login
              AppLayout.gapBeforeCtaBox,

              // CTA 1
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    elevation: const MaterialStatePropertyAll(0),
                    foregroundColor: const MaterialStatePropertyAll(AppColors.ctaFg),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed)) return AppColors.ctaBgPressed;
                      if (states.contains(MaterialState.hovered)) return AppColors.ctaBgHover;
                      return AppColors.ctaBg;
                    }),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Create New Account',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),

              AppLayout.gapLG,

              // CTA 2
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.brandOrange, width: 1.6),
                    foregroundColor: AppColors.brandOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Log In to Existing Account',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              // KHÔNG thêm SizedBox cuối để tránh “đội padding” so với Login
            ],
          ),
        ),
      ),
    );
  }
}
