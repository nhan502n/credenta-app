import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
  String? _err;

  late final AnimationController _checkCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _checkAnim =
      CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOutBack);

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _err = null;
      });
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
      await ctrl.initialize(); // Trên web: sẽ hiện prompt nếu chưa cấp quyền
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
      });
    } on CameraException catch (e) {
      // Các lỗi hay gặp trên web: NotAllowedError, NotFoundError, NotReadableError...
      setState(() => _err = e.description ?? e.code);
    } catch (e) {
      setState(() => _err = e.toString());
    }
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _shoot() async {
    final cam = _controller;
    if (cam == null || !cam.value.isInitialized) return;
    try {
      await cam.takePicture();
      if (!mounted) return;

      setState(() => _isVerifying = true);
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      _checkCtrl.forward();

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _AskAnotherSheet(
          onYes: () {
            Navigator.pop(context);
            setState(() {
              _isSuccess = false;
              _checkCtrl.reset();
            });
            Navigator.pop(context);
            Navigator.pushNamed(context, '/register-document/types');
          },
          onNo: () {
            Navigator.pop(context);
            Navigator.popUntil(context, ModalRoute.withName('/my-documents'));
          },
        ),
      );

      if (mounted) {
        setState(() => _isSuccess = false);
        _checkCtrl.reset();
      }
    } catch (e) {
      setState(() => _err = e.toString());
    }
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
                              return const Center(child: CircularProgressIndicator());
                            }
                            return const SizedBox.shrink(); // controller set trong _initCamera
                          },
                        )
                      : CameraPreview(cam),
            ),

            // Close (X)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.brandOrange),
              ),
            ),

            // Frame + hint
            const _FrameOverlay(),

            // Shutter button
            if (_err == null)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _isVerifying ? null : _shoot,
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 54,
                          height: 54,
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

            // Verifying overlay
            if (_isVerifying)
              Positioned.fill(
                child: Container(
                  color: AppColors.bg.withOpacity(0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          color: AppColors.brandOrange,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text('Verifying document...',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),

            // Success overlay
            if (_isSuccess)
              Positioned.fill(
                child: Align(
                  alignment: const Alignment(0, 0.65),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _checkAnim,
                        child: Icon(Icons.check,
                            color: Colors.greenAccent.shade400, size: 48),
                      ),
                      const SizedBox(height: 16),
                      const Text('Register document successfully!',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FrameOverlay extends StatelessWidget {
  const _FrameOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameW = size.width - 56;
    final frameH = frameW * 0.56;

    return IgnorePointer(
      ignoring: true,
      child: Column(
        children: [
          const Spacer(flex: 3),
          Center(
            child: Container(
              width: frameW,
              height: frameH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brandCream, width: 3),
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
          const Spacer(flex: 4),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off, color: Colors.white70, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          if (isWeb)
            const Text(
              'Tip (Web):\n• Chạy trên HTTPS hoặc localhost\n'
              '• Nếu từng bấm Block, bấm vào biểu tượng ổ khóa cạnh thanh địa chỉ ➜ Site settings ➜ Camera: Allow ➜ Reload trang',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          const SizedBox(height: 16),
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

class _AskAnotherSheet extends StatelessWidget {
  const _AskAnotherSheet({required this.onYes, required this.onNo});
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Do you want to\nregister another document?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
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
