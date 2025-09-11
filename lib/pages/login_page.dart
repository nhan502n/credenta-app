import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import 'package:animations/animations.dart';           // 👈 hiệu ứng FadeThrough
import 'phone_verify_page.dart';   

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _FadeThroughRoute<T> extends PageRouteBuilder<T> {
  _FadeThroughRoute(Widget page)
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          opaque: true,
          maintainState: true,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              secondaryAnimation:
                  CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
              child: child,
            );
          },
        );
}
class _LoginPageState extends State<LoginPage> {
  int step = 0;

  final _emailFormKey = GlobalKey<FormState>();
  final _passFormKey  = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();

  bool showPass = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  double _fieldHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final candidate = w * 0.09; // ~9% width
    return candidate.clamp(30.0, 36.0);
  }

  InputDecoration _decoration(
    String hint,
    double fieldH, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    const borderW = 1.2;
    final double vPad = ((fieldH - 18) / 2).clamp(5.0, 10.0);

    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: 14),
      filled: true,
      fillColor: AppColors.inputFill50,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      suffixIconConstraints: BoxConstraints.tightFor(width: fieldH, height: fieldH),
      suffixIcon: isPassword
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: AppColors.brandOrange,
              ),
              onPressed: () => setState(() => showPass = !showPass),
            )
          : (controller != null && controller.text.isNotEmpty)
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_outlined, size: 18, color: AppColors.clearX),
                  onPressed: () { controller.clear(); setState(() {}); },
                )
              : const SizedBox.shrink(),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      );

  Widget _validatedField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String value)? validator,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) => validator?.call(controller.text),
      builder: (state) {
        final fieldH = _fieldHeight(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(label),
            SizedBox(
              height: fieldH,
              child: TextFormField(
                controller: controller,
                obscureText: isPassword ? !showPass : false,
                keyboardType: keyboardType,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.0),
                strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0.0, fontSize: 14),
                decoration: _decoration(hint, fieldH, isPassword: isPassword, controller: controller),
                onChanged: (v) => setState(() => state.didChange(v)),
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
              ),
            ),
            SizedBox(
              height: 16,
              child: (state.errorText == null || state.errorText!.isEmpty)
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(state.errorText!,
                          style: const TextStyle(color: AppColors.brandOrange, fontSize: 12, height: 1)),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _backButton(BuildContext context, {VoidCallback? onTap}) => GestureDetector(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(color: AppColors.backCircle, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: AppColors.brandOrange, size: 20),
        ),
      );

  ButtonStyle _ctaStyle() => ButtonStyle(
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

  // ---------- EMAIL STEP ----------
  Widget _emailContent(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 380;
    return Form(
      key: _emailFormKey, // <-- Quan trọng
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(context),
          const SizedBox(height: 16),
          Text('Log in with your Email Address',
              style: TextStyle(color: AppColors.title, fontSize: isNarrow ? 22 : 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _validatedField(
            label: 'Email',
            hint: 'Your Email Address',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final t = v.trim();
              if (t.isEmpty) return 'Required';
              final ok = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(t);
              return ok ? null : 'Invalid email';
            },
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: AppColors.textPrimary, height: 1.35),
              children: [
                TextSpan(text: "By submitting your email, you confirm you’ve read this "),
                TextSpan(text: 'Terms of Use',
                    style: TextStyle(decoration: TextDecoration.underline, color: AppColors.brandOrange)),
                TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy',
                    style: TextStyle(decoration: TextDecoration.underline, color: AppColors.brandOrange)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- PASSWORD STEP ----------
  Widget _passwordContent(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 380;
    return Form(
      key: _passFormKey, // <-- Quan trọng
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(context, onTap: () => setState(() => step = 0)),
          const SizedBox(height: 16),
          Text('Enter your Password',
              style: TextStyle(color: AppColors.title, fontSize: isNarrow ? 22 : 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _validatedField(
            label: 'Password',
            hint: 'Your Password',
            controller: passCtrl,
            isPassword: true,
            validator: (v) => (v.length < 6) ? 'Min 6 chars' : null,
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Forgot Password'),
            ),
          ),
          if (emailCtrl.text.isNotEmpty)
            const SizedBox(height: 8),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppLayout.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: step == 0 ? _emailContent(context) : _passwordContent(context),
                ),
              ),
              AppLayout.gapBeforeCtaBox,
SizedBox(
  height: 52,
  child: ElevatedButton(
    style: _ctaStyle(),
    onPressed: () {
      if (step == 0) {
        final f = _emailFormKey.currentState!;
        if (!f.validate()) return;
        setState(() => step = 1);
      } else {
        final f = _passFormKey.currentState!;
        if (!f.validate()) return;

        // ✅ Điều hướng sang trang xác minh số điện thoại
        Navigator.of(context).push(
          _FadeThroughRoute(
            const PhoneVerifyPage(), // nếu cần truyền email thì thêm param tại constructor của PhoneVerifyPage
          ),
        );
      }
    },
    child: const Text(
      'Log In',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    ),
  ),
)

            ],
          ),
        ),
      ),
    );
  }
}
