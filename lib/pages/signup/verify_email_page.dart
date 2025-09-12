import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';

class VerifyEmailPage extends StatelessWidget {
  final String email; // truyền email để hiển thị
  const VerifyEmailPage({super.key, required this.email});

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
    final isNarrow = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          // ✅ đồng bộ padding 4 phía
          padding: AppLayout.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mũi tên BÊN TRÁI
              Align(
                alignment: Alignment.centerLeft,
                child: _backButton(context),
              ),

              AppLayout.gapLG,

              // Nội dung căn giữa dọc
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon mail
                      Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.clearX, width: 1.2),
                        ),
                        child: const Icon(Icons.mail_outline, size: 28, color: AppColors.brandCream),
                      ),

                      AppLayout.gapLG,

                      // Title — đổi sang TRẮNG
                      Text(
                        'Verify Email Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary, // 🔁 trắng
                          fontSize: isNarrow ? 22 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      AppLayout.gapSM,

                      // Description — trắng
                      Text(
                        'An email was sent to $email.\n'
                        'Verify your email with the link to continue.\n'
                        "If you can’t find it, please check your spam or junk folder.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),

              // Link ở đáy — màu cam
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: resend email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification email resent')),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandOrange, // 🔁 chỉ dòng này màu cam
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Didn't receive an email?"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
