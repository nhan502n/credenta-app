import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import 'document_types_page.dart'; // 👈 import thêm

class MyDocumentsPage extends StatelessWidget {
  const MyDocumentsPage({super.key});

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

  Widget _backButton(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.backCircle,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.brandOrange, size: 20),
        ),
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
              // Top bar
              SizedBox(
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _backButton(context),
                    ),
                    Text(
                      'My documents',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isNarrow ? 22 : 24,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Empty-state icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandCream.withOpacity(0.8),
                      width: 1.6,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.folder_open_outlined,
                      size: 28,
                      color: AppColors.brandCream,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Empty-state text
              const Text(
                'No documents yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start by adding your first document to see it here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),

              const Spacer(),

              AppLayout.gapBeforeCtaBox,

              // Primary CTA -> đi sang DocumentTypesPage
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: _primaryCtaStyle(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DocumentTypesPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Register new document',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),

              AppLayout.gapLG,

              // Secondary CTA
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
                    Navigator.pushNamed(context, '/add-child-profile');
                  },
                  child: const Text(
                    'Add New Child Sub Profile',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
