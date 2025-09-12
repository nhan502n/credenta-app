import 'package:flutter/material.dart';
import '../../theme/app_layout.dart';
import '../../theme/app_colors.dart';
import '../document/document_types_page.dart'; // 👈 THÊM

class LandingPageFake extends StatelessWidget {
  const LandingPageFake({super.key});

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
    final isNarrow = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppLayout.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/my-documents'),
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

              AppLayout.gapBeforeCtaBox,

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: _primaryCtaStyle(),
                  onPressed: () {
                    // 1) Clear stack và đưa MyDocuments lên
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/my-documents',
                      (_) => false,
                    );
                    // 2) Đẩy DocumentTypes lên trên MyDocuments (giống _onAskYes)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushNamed(context, DocumentTypesPage.route);
                    });
                  },
                  child: const Text(
                    'Register new document',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),

              AppLayout.gapLG,

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
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  },
                  child: const Text('Log out',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
