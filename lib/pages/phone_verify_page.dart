import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:frontend/pages/country_code_picker_page.dart';
import 'package:frontend/pages/phone_otp_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../services/country_service.dart'
    show CountryDial, flagEmoji, prefetchCountryDials, fetchCountryDialsCached;

class PhoneVerifyPage extends StatefulWidget {
  const PhoneVerifyPage({super.key});

  @override
  State<PhoneVerifyPage> createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends State<PhoneVerifyPage> {
  final _formKey = GlobalKey<FormState>();

  CountryDial _selected =
      CountryDial(name: 'United States', cca2: 'US', dial: '+1');
  final phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Warm cache để khi mở picker không khựng
    prefetchCountryDials();
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    super.dispose();
  }

  // ===== layout helpers (đồng bộ với LoginPage) =====

  Widget _backButton(BuildContext context, {VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
              color: AppColors.backCircle, shape: BoxShape.circle),
          child:
              const Icon(Icons.arrow_back, color: AppColors.brandOrange, size: 20),
        ),
      );

  double _fieldHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final candidate = w * 0.09; // ~9% width
    return candidate.clamp(30.0, 36.0);
  }

  InputDecoration _decoration(
    String hint,
    double fieldH, {
    TextEditingController? controller,
  }) {
    const borderW = 1.2;
    final vPad = ((fieldH - 18) / 2).clamp(5.0, 10.0);

    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: 14),
      filled: true,
      fillColor: AppColors.inputFill50,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide:
            const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide:
            const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide:
            const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        borderSide:
            const BorderSide(color: AppColors.brandOrange, width: borderW),
      ),
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      suffixIconConstraints:
          BoxConstraints.tightFor(width: fieldH, height: fieldH),
      suffixIcon: (controller != null && controller.text.isNotEmpty)
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close_outlined,
                  size: 18, color: AppColors.clearX),
              onPressed: () {
                controller.clear();
                setState(() {});
              },
            )
          : const SizedBox.shrink(),
    );
  }

  ButtonStyle _ctaStyle() => ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        elevation: const MaterialStatePropertyAll(0),
        foregroundColor: const MaterialStatePropertyAll(AppColors.ctaFg),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return AppColors.ctaBgPressed;
          }
          if (states.contains(MaterialState.hovered)) {
            return AppColors.ctaBgHover;
          }
          return AppColors.ctaBg;
        }),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      );

  // ===== navigation =====
  Future<void> _openCountryPicker() async {
    final prefetched = await fetchCountryDialsCached();
    final picked = await Navigator.push<CountryDial>(
      context,
      _FadeThroughRoute<CountryDial>(
        CountryCodePickerPage(prefetched: prefetched),
      ),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _selected = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 380;
    final h = _fieldHeight(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppLayout.pagePadding, // ✅ giống LoginPage
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== content scrollable (đồng bộ LoginPage) =====
              Expanded(
                child: SingleChildScrollView(
                  child: Form( // ⬅️ THÊM: bọc form để validate
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _backButton(context),
                        const SizedBox(height: 16),
                        Text(
                          'What is your mobile number?',
                          style: TextStyle(
                            color: AppColors.title,
                            fontSize: isNarrow ? 22 : 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label('Mobile Number'),

                        // country code + phone (same height)
                        Row(
                          children: [
                            SizedBox(
                              height: h,
                              child: _CountryCodeButton(
                                height: h,
                                dial: _selected.dial,
                                flag: flagEmoji(_selected.cca2),
                                onTap: _openCountryPicker,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: h,
                                child: TextFormField(
                                  controller: phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      height: 1),
                                  strutStyle: const StrutStyle(
                                      forceStrutHeight: true,
                                      height: 1,
                                      fontSize: 14),
                                  decoration: _decoration('Your mobile number', h,
                                      controller: phoneCtrl),
                                  validator: (v) {
                                    final t =
                                        (v ?? '').replaceAll(RegExp(r'\D'), '');
                                    if (t.isEmpty) return 'Required';
                                    if (t.length < 6 || t.length > 15) {
                                      return 'Invalid phone number';
                                    }
                                    return null;
                                  },
                                  maxLines: 1,
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text.rich(
                          TextSpan(
                            style: TextStyle(
                                color: AppColors.textPrimary, height: 1.35),
                            children: [
                              TextSpan(
                                  text:
                                      "By submitting your email, you confirm you’ve read this "),
                              TextSpan(
                                text: 'Terms of Use',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AppColors.brandOrange),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AppColors.brandOrange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== gap + CTA cố định đáy (đồng bộ LoginPage) =====
              AppLayout.gapBeforeCtaBox,
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: _ctaStyle(),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != true) return;

                    // Ẩn bàn phím cho gọn
                    FocusScope.of(context).unfocus();

                    // Làm sạch số và tạo text hiển thị
                    final digits =
                        phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
                    final display = '${_selected.dial} $digits';

                    // TODO: gửi OTP qua API nếu có backend
                    // await sendOtp(phone: '$_selected$dial$digits');

                    // Điều hướng sang trang nhập OTP (hiệu ứng FadeThrough)
                    Navigator.of(context).push(
                      _FadeThroughRoute(
                        PhoneOtpPage(phoneDisplay: display),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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

/// Looks like an input; opens the picker page.
class _CountryCodeButton extends StatelessWidget {
  final double height;
  final String flag;
  final String dial;
  final VoidCallback onTap;

  const _CountryCodeButton({
    super.key,
    required this.height,
    required this.flag,
    required this.dial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.inputRadius),
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.inputFill50,
            borderRadius: BorderRadius.circular(AppColors.inputRadius),
            border: Border.all(color: AppColors.brandOrange, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(dial,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down,
                  color: AppColors.brandOrange, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route Material Motion: FadeThrough
class _FadeThroughRoute<T> extends PageRouteBuilder<T> {
  _FadeThroughRoute(Widget page)
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          opaque: true,
          maintainState: true,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic),
              secondaryAnimation: CurvedAnimation(
                  parent: secondaryAnimation, curve: Curves.easeOutCubic),
              child: child,
            );
          },
        );
}
