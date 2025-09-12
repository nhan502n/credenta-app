import 'package:flutter/material.dart';
import 'package:frontend/pages/signup/verify_email_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final firstCtrl = TextEditingController();
  final middleCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool showPass1 = false;
  bool showPass2 = false;
  bool agreeTOS = false;
  bool subscribe = false;

  @override
  void dispose() {
    firstCtrl.dispose();
    middleCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }


  InputDecoration _decoration(
    String hint,
    double fieldH, {
    bool isPassword = false,
    int pwdIndex = 0,
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
        borderSide: const BorderSide(
          color: AppColors.brandOrange,
          width: borderW,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.brandOrange,
          width: borderW,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.brandOrange,
          width: borderW,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.brandOrange,
          width: borderW,
        ),
      ),
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      suffixIconConstraints: BoxConstraints.tightFor(
        width: fieldH,
        height: fieldH,
      ),
      suffixIcon: isPassword
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                (pwdIndex == 1 ? showPass1 : showPass2)
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.brandOrange,
              ),
              onPressed: () => setState(() {
                if (pwdIndex == 1) {
                  showPass1 = !showPass1;
                } else {
                  showPass2 = !showPass2;
                }
              }),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _validatedField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String value)? validator,
    bool isPassword = false,
    int pwdIndex = 0,
    TextInputType? keyboardType,
  }) {
    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) => validator?.call(controller.text),
      builder: (state) {
        final fieldH = AppLayout.fieldHeight(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(label),
            SizedBox(
              height: fieldH,
              child: TextFormField(
                controller: controller,
                obscureText: isPassword
                    ? !(pwdIndex == 1 ? showPass1 : showPass2)
                    : false,
                keyboardType: keyboardType,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.0,
                ),
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  height: 1.0,
                  leading: 0.0,
                  fontSize: 14,
                ),
                decoration: _decoration(
                  hint,
                  fieldH,
                  isPassword: isPassword,
                  pwdIndex: pwdIndex,
                ),
                onChanged: (v) => state.didChange(v),
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
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(
                          color: AppColors.brandOrange,
                          fontSize: 12,
                          height: 1,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _backButton(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.backCircle,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_back,
        color: AppColors.brandOrange,
        size: 20,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ đồng bộ padding với Login/Landing
          padding: AppLayout.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backButton(context),
                AppLayout.gapMD,

                Text(
                  'Create an Account',
                  style: TextStyle(
                    color: AppColors.title,
                    fontSize: isNarrow ? 22 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppLayout.gapMD,

                _validatedField(
                  label: 'First Name',
                  hint: 'First Name',
                  controller: firstCtrl,
                  validator: (v) => v.trim().isEmpty ? 'Required' : null,
                ),
                AppLayout.gapXS,

                _validatedField(
                  label: 'Middle Name',
                  hint: 'Middle Name',
                  controller: middleCtrl,
                ),
                AppLayout.gapXS,

                _validatedField(
                  label: 'Last Name',
                  hint: 'Last Name',
                  controller: lastCtrl,
                  validator: (v) => v.trim().isEmpty ? 'Required' : null,
                ),
                AppLayout.gapXS,

                _validatedField(
                  label: 'Email',
                  hint: 'Email',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v.trim().isEmpty) return 'Required';
                    final ok = RegExp(
                      r'^[\w\.-]+@[\w\.-]+\.\w+$',
                    ).hasMatch(v.trim());
                    return ok ? null : 'Invalid email';
                  },
                ),
                AppLayout.gapXS,

                _validatedField(
                  label: 'Password',
                  hint: 'Password',
                  controller: passCtrl,
                  isPassword: true,
                  pwdIndex: 1,
                  validator: (v) => v.length < 6 ? 'Min 6 chars' : null,
                ),
                AppLayout.gapXS,

                _validatedField(
                  label: 'Confirm Password',
                  hint: 'Confirm Password',
                  controller: pass2Ctrl,
                  isPassword: true,
                  pwdIndex: 2,
                  validator: (v) =>
                      v != passCtrl.text ? 'Passwords do not match' : null,
                ),
                AppLayout.gapMD,

                // Checkboxes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: agreeTOS,
                      onChanged: (v) => setState(() => agreeTOS = v ?? false),
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => states.contains(MaterialState.selected)
                            ? AppColors.checkboxFillChecked
                            : Colors.transparent,
                      ),
                      checkColor: AppColors.checkboxTick,
                      side: const BorderSide(
                        color: AppColors.checkboxBorder,
                        width: 1.6,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  "I acknowledge that I have read and agree to XXX's ",
                            ),
                            TextSpan(
                              text: 'Terms of Use',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.brandOrange,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.brandOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                AppLayout.gapXS,

                Row(
                  children: [
                    Checkbox(
                      value: subscribe,
                      onChanged: (v) => setState(() => subscribe = v ?? false),
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => states.contains(MaterialState.selected)
                            ? AppColors.checkboxFillChecked
                            : Colors.transparent,
                      ),
                      checkColor: AppColors.checkboxTick,
                      side: const BorderSide(
                        color: AppColors.checkboxBorder,
                        width: 1.6,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'I would like to receive XXX exclusive offers and updates',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),

                // ✅ khoảng trống trước CTA dùng chung
                AppLayout.gapBeforeCtaBox,

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      elevation: const MaterialStatePropertyAll(0),
                      foregroundColor: const MaterialStatePropertyAll(
                        AppColors.ctaFg,
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.pressed))
                            return AppColors.ctaBgPressed;
                          if (states.contains(MaterialState.hovered))
                            return AppColors.ctaBgHover;
                          return AppColors.ctaBg;
                        },
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (!_formKey.currentState!.validate()) return;
                      if (!agreeTOS) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please agree to Terms of Use & Privacy Policy.',
                            ),
                          ),
                        );
                        return;
                      }

                      // TODO: gọi API đăng ký -> thành công thì điều hướng:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VerifyEmailPage(
                            email: emailCtrl.text.trim().isEmpty
                                ? 'example@email.com'
                                : emailCtrl.text.trim(),
                          ),
                        ),
                      );
                    },

                    child: const Text(
                      'Create New Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
