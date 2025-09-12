import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/pages/document/document_camera_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';

class DocumentScanPage extends StatelessWidget {
  const DocumentScanPage({super.key, this.type});
  final String? type;

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

  Widget _closeButton(BuildContext context) => IconButton(
        onPressed: () => Navigator.pop(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        icon: const Icon(Icons.close, color: AppColors.brandOrange, size: 20),
      );

  Widget _badgeImg({
    required String asset,
    required bool ok,
    double imgSize = 40,
    double badgeSize = 14,
    double iconSize = 10,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: imgSize,
          height: imgSize,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) {
              debugPrint('Asset error: $asset => $error');
              return const Icon(Icons.error, color: Colors.red, size: 20);
            },
          ),
        ),
        Positioned(
          right: -5,
          top: -5,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: ok ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bg, width: 1.5),
            ),
            child: Icon(ok ? Icons.check : Icons.close, color: Colors.white, size: iconSize),
          ),
        ),
      ],
    );
  }

Future<void> _goToCamera(BuildContext context) async {
  if (!kIsWeb) {
    final status = await Permission.camera.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    if (!status.isGranted) {
      final res = await Permission.camera.request();
      if (!res.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to scan')),
        );
        return;
      }
    }
  }
  // Web: trình duyệt sẽ hỏi quyền khi trang camera khởi tạo controller
  // ignore: use_build_context_synchronously
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DocumentCameraPage()),
  );
}


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
              SizedBox(
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Scan time!',
                        style: TextStyle(
                          color: AppColors.title,
                          fontSize: isNarrow ? 22 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Align(alignment: Alignment.centerRight, child: _closeButton(context)),
                  ],
                ),
              ),

              const Spacer(),

              const Text(
                'Prepare your document',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badgeImg(asset: 'assets/images/face_1.png', ok: true),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Have a valid identity document ready',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badgeImg(asset: 'assets/images/id-card_1.png', ok: false),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.35),
                        children: [
                          TextSpan(text: 'Ensure the document is '),
                          TextSpan(text: 'not damaged, not expired,', style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: '\nand '),
                          TextSpan(text: 'clearly visible.', style: TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              AppLayout.gapBeforeCtaBox,

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: _primaryCtaStyle(),
                  onPressed: () => _goToCamera(context),
                  child: const Text('Go', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
