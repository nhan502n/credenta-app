import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Chiều cao input responsive: min 30, max 36
double fieldHeight(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return (w * 0.09).clamp(30.0, 36.0);
}

/// InputDecoration chuẩn, nhận height để tính padding + slot icon
InputDecoration appInputDecoration(
  String hint,
  double h, {
  bool withSuffixSlot = true,
  Widget? suffix,
}) {
  const bw = 1.2;
  final vPad = ((h - 18) / 2).clamp(5.0, 10.0); // font 14 ~18px

  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: 14),
    filled: true,
    fillColor: AppColors.inputFill50,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.inputRadius),
      borderSide: const BorderSide(color: AppColors.brandOrange, width: bw),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.inputRadius),
      borderSide: const BorderSide(color: AppColors.brandOrange, width: bw),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.inputRadius),
      borderSide: const BorderSide(color: AppColors.brandOrange, width: bw),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.inputRadius),
      borderSide: const BorderSide(color: AppColors.brandOrange, width: bw),
    ),
    errorStyle: const TextStyle(fontSize: 0, height: 0),

    suffixIconConstraints:
        BoxConstraints.tightFor(width: withSuffixSlot ? h : 0, height: h),
    suffixIcon: suffix ?? (withSuffixSlot ? const SizedBox.shrink() : null),
  );
}

/// Label đậm
Widget fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    );

/// Nút back tròn dùng chung
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AppColors.backCircle,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back,
            color: AppColors.brandOrange, size: 20),
      ),
    );
  }
}
