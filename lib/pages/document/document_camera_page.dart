import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/pages/document/document_types_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';

class DocumentCameraPage extends StatefulWidget {
  const DocumentCameraPage({super.key, this.type});
  final String? type;

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initFuture;

  bool _isVerifying = false;
  bool _isSuccess = false;
  bool _askAnother = false;
  String? _err;

  bool _aborted = false;

  // Check animation (giống bản cũ)
  late final AnimationController _checkCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _checkScale =
      CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOutBack);
  late final Animation<double> _checkFade =
      CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOutCubic);

  // Demo delay cho verify (có thể xóa khi gắn BE)
  static const _demoVerifyMs = 1400;

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      setState(() => _err = null);
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _err = 'No camera available.');
        return;
      }
      final preset = kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high;
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(back, preset, enableAudio: false);
      await ctrl.initialize(); // Web sẽ prompt quyền nếu chưa cấp
      if (!mounted) return;
      setState(() => _controller = ctrl);
    } on CameraException catch (e) {
      setState(() => _err = e.description ?? e.code);
    } catch (e) {
      setState(() => _err = e.toString());
    }
  }

  Future<void> _shoot() async {
    final cam = _controller;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      _aborted = false;
      await cam.takePicture();
      if (!mounted) return;

      // Overlay verify đơn giản (bản cũ)
      setState(() => _isVerifying = true);

      // ⏳ Demo delay — bỏ khi gắn BE
      await Future.delayed(const Duration(milliseconds: _demoVerifyMs));
      if (!mounted || _aborted) return;

      // Thành công
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      _checkCtrl.forward();

      // Đợi 1 nhịp rồi mở bottom sheet Yes/No
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted || _aborted) return;

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _AskAnotherSheet(
          onYes: _onAskYes,
          onNo: _onAskNo,
        ),
      );

      if (mounted) {
        setState(() {
          _isSuccess = false;
          _checkCtrl.reset();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _err = e.toString());
    }
  }

  // Hủy verify và quay lại bước trước
  void _cancelVerifyAndBack() {
    _aborted = true;
    if (mounted) {
      setState(() => _isVerifying = false);
      Navigator.pop(context);
    }
  }

  // YES: quay về Document types, giữ lại /my-documents bên dưới
  void _onAskYes() {
    Navigator.pop(context); // đóng sheet
    Navigator.of(context).pushNamedAndRemoveUntil(
      DocumentTypesPage.route,                 // '/register-document/types'
      ModalRoute.withName('/my-documents'),   // giữ lại MyDocuments ở dưới
    );
  }

  // NO: về My documents
  void _onAskNo() {
    Navigator.pop(context); // đóng sheet
    Navigator.popUntil(context, ModalRoute.withName('/my-documents'));
  }

  @override
  Widget build(BuildContext context) {
    final cam = _controller;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview / lỗi
            Positioned.fill(
              child: _err != null
                  ? _ErrorHelp(
                      message: _err!,
                      onRetry: _initCamera,
                      isWeb: kIsWeb,
                    )
                  : (cam == null)
                      ? FutureBuilder(
                          future: _initFuture,
                          builder: (_, snap) {
                            if (snap.connectionState != ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(color: AppColors.brandOrange),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      : CameraPreview(cam),
            ),

            // Close (X) — căn theo AppLayout.pagePadding
            if (!_isVerifying)
              Positioned.fill(
                child: Padding(
                  padding: AppLayout.pagePadding,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.brandOrange),
                    ),
                  ),
                ),
              ),

            // Khung & hint
            if (!_isVerifying) const _ScanMaskOverlay(),

            // Nút chụp — căn dưới theo AppLayout.pagePadding
            if (_err == null && !_isVerifying)
              Positioned.fill(
                child: Padding(
                  padding: AppLayout.pagePadding,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: _shoot,
                      child: Container(
                        width: 66, height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ===== VERIFY OVERLAY (full-page, dùng AppLayout) =====
            if (_isVerifying)
              Positioned.fill(
                child: Container(
                  color: AppColors.bg,
                  child: Padding(
                    padding: AppLayout.pagePadding,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 56, height: 56,
                                child: CircularProgressIndicator(
                                  strokeWidth: 5.5,
                                  color: AppColors.brandOrange,
                                ),
                              ),
                              AppLayout.gapLG,
                              Text(
                                'Verifying document...',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: _cancelVerifyAndBack,
                            icon: const Icon(Icons.close, color: AppColors.brandOrange),
                            tooltip: 'Back',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ===== SUCCESS OVERLAY (full-page, dùng AppLayout) =====
            if (_isSuccess)
              Positioned.fill(
                child: Container(
                  color: AppColors.bg,
                  child: Padding(
                    padding: AppLayout.pagePadding,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _checkFade,
                            child: ScaleTransition(
                              scale: _checkScale,
                              child: Icon(Icons.check,
                                  color: Colors.greenAccent.shade400, size: 56),
                            ),
                          ),
                          AppLayout.gapLG,
                          const Text(
                            'Register document successfully!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mask tối + khung + nhãn gợi ý (dùng AppLayout cho margin)
class _ScanMaskOverlay extends StatelessWidget {
  const _ScanMaskOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double marginH = AppLayout.padH;
    final double frameW = size.width - marginH * 2;
    final double frameH = frameW * 0.56;

    // Vị trí khung: ưu tiên khoảng 38% chiều cao, nhưng không chạm phần padding trên
    double top = size.height * 0.38 - frameH / 2;
    if (top < AppLayout.padV) top = AppLayout.padV;

    final Rect hole = Rect.fromLTWH(marginH, top, frameW, frameH);
    final rrect = RRect.fromRectAndRadius(hole, const Radius.circular(12));

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MaskPainter(rrect))),
          Positioned(
            top: hole.bottom + AppLayout.gapMD.height!,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.brandCream,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Fit the document into the frame',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaskPainter extends CustomPainter {
  _MaskPainter(this.hole);
  final RRect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withOpacity(0.60);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    final border = Paint()
      ..color = AppColors.brandCream
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(hole, border);
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) => oldDelegate.hole != hole;
}

/// Bottom sheet Yes/No (bản cũ) — padding theo AppLayout
class _AskAnotherSheet extends StatelessWidget {
  const _AskAnotherSheet({required this.onYes, required this.onNo});
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.padH, AppLayout.padV, AppLayout.padH, AppLayout.padV / 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Do you want to\nregister another document?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            AppLayout.gapLG,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNo,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.brandOrange, width: 1.6),
                      foregroundColor: AppColors.brandOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('No'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onYes,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.brandOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Yes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorHelp extends StatelessWidget {
  const _ErrorHelp({
    required this.message,
    required this.onRetry,
    required this.isWeb,
  });

  final String message;
  final Future<void> Function() onRetry;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      alignment: Alignment.center,
      padding: AppLayout.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off, color: Colors.white70, size: 40),
          AppLayout.gapLG,
          Text(message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
          AppLayout.gapLG,
          if (isWeb)
            const Text(
              'it is not supported to access camera on web.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          AppLayout.gapLG,
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
