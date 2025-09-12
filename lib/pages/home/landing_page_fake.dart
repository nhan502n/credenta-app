import 'package:flutter/material.dart';
import '../../theme/app_layout.dart';
import '../../theme/app_colors.dart';

/// Temporary landing page (no token). Keep this simple to merge later.
/// TODO(merge): Replace with real LandingPage when auth/token is ready.
class LandingPageFake extends StatelessWidget {
  const LandingPageFake({super.key});

  // Reuse the CTA style you’re already using elsewhere
  ButtonStyle _primaryCtaStyle() => ButtonStyle(
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
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 380;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppLayout.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top-right link "My document"
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO(route): navigate to your documents list page
                      Navigator.pushNamed(context, '/my-documents');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandOrange,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('My document'),
                  ),
                ],
              ),

              // Center title
              const Spacer(),
              Text(
                'App Dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFECDFCC),
                  fontSize: isNarrow ? 26 : 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),

              // Spacing before CTAs (shared)
              AppLayout.gapBeforeCtaBox,

              // Primary CTA: Register new document
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: _primaryCtaStyle(),
                  onPressed: () {
                    // TODO(route): navigate to register/new document flow
                    Navigator.pushNamed(context, '/register-document');
                  },
                  child: const Text(
                    'Register new document',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),

              AppLayout.gapLG,

              // Secondary CTA: Log out (outlined)
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.brandOrange, width: 1.6),
                    foregroundColor: AppColors.brandOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    // TODO(auth): clear temp session then go to login/landing
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  child: const Text(
                    'Log out',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              // No extra bottom spacer to keep same visual padding as other pages
            ],
          ),
        ),
      ),
    );
  }
}
