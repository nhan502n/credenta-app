import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';

class PhoneOtpPage extends StatefulWidget {
  final String phoneDisplay; // text shown in the description line
  const PhoneOtpPage({super.key, this.phoneDisplay = '+0123456789'});

  @override
  State<PhoneOtpPage> createState() => _PhoneOtpPageState();
}

class _PhoneOtpPageState extends State<PhoneOtpPage> {
  // ===== OTP state =====
  static const int _len = 6;
  static const String _mockOtp = '111111'; // <-- MOCK OTP

  final _nodes =
      List<FocusNode>.generate(_len, (_) => FocusNode(debugLabel: 'otp'));
  final _ctrs =
      List<TextEditingController>.generate(_len, (_) => TextEditingController());

  // resend countdown
  static const int _resendSeconds = 30;
  int _left = _resendSeconds;
  Timer? _t;

  // status line (green when verified / red when invalid)
  String? _statusText;
  Color _statusColor = Colors.green;
  bool _isError = false; // toggle red border when OTP is invalid

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _t?.cancel();
    for (final n in _nodes) n.dispose();
    for (final c in _ctrs) c.dispose();
    super.dispose();
  }

  void _startTimer() {
    _t?.cancel();
    setState(() => _left = _resendSeconds);
    _t = Timer.periodic(const Duration(seconds: 1), (tm) {
      if (!mounted) return;
      if (_left <= 1) {
        tm.cancel();
        setState(() => _left = 0);
      } else {
        setState(() => _left--);
      }
    });
  }

  String get _code => _ctrs.map((c) => c.text).join();

  void _onChanged(int i, String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      if (_ctrs[i].text.isEmpty && i > 0) {
        _nodes[i - 1].requestFocus();
        _ctrs[i - 1].selection =
            TextSelection.collapsed(offset: _ctrs[i - 1].text.length);
      }
      setState(() {
        _ctrs[i].text = '';
        _isError = false; // reset error when user edits
        _statusText = null;
      });
      return;
    }

    if (digits.length > 1) {
      int idx = i;
      for (final ch in digits.split('')) {
        if (idx >= _len) break;
        _ctrs[idx].text = ch;
        idx++;
      }
      if (idx < _len) {
        _nodes[idx].requestFocus();
      } else {
        _nodes[_len - 1].unfocus();
      }
    } else {
      _ctrs[i].text = digits;
      if (i < _len - 1) {
        _nodes[i + 1].requestFocus();
      } else {
        _nodes[i].unfocus();
      }
    }

    setState(() {
      _isError = false; // reset error on change
      _statusText = null;
    });

    if (_code.length == _len && !_code.contains(RegExp(r'[^0-9]'))) {
      _verify();
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    if (_code == _mockOtp) {
      setState(() {
        _statusText = 'OTP verified successfully';
        _statusColor = Colors.green;
        _isError = false;
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _statusText = 'Invalid verification code. Please try again.';
        _statusColor = Colors.red;
        _isError = true;
      });
    }
  }

  void _clearAll() {
    for (final c in _ctrs) c.clear();
    _nodes.first.requestFocus();
    setState(() {
      _statusText = null;
      _isError = false;
    });
  }

  ButtonStyle _resendStyle(bool enabled) => TextButton.styleFrom(
        foregroundColor: enabled ? AppColors.brandOrange : AppColors.placeholder,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          // use AppLayout for global padding
          padding: AppLayout.pagePadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // back
                GestureDetector(
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
                ),

                // spacing
                AppLayout.gapLG,

                const Text(
                  'Verify your mobile number',
                  style: TextStyle(
                    color: AppColors.title,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                AppLayout.gapLG,

                const Text(
                  'Verification Code (SMS)',
                  style: TextStyle(color: AppColors.textPrimary),
                ),

                AppLayout.gapMD,

                // ===== OTP grid (keeps 39x50 baseline, scales) & double space after 3rd cell =====
                LayoutBuilder(
                  builder: (_, cons) {
                    // Baseline (393 × 852)
                    const double baseW = 39.0;
                    const double baseH = 50.0;
                    const double baseGap = 12.0;

                    // Total width baseline with double gap after idx==2:
                    // 6*(w) + 5*(gap) + 1*(extra gap) = 6*39 + 6*12 - (remove last gap) + extra
                    // For simplicity, we keep the provided constant:
                    const double totalBase = 306.0;

                    double scale = cons.maxWidth / totalBase;
                    scale = scale.clamp(0.90, 1.25);

                    final double w = baseW * scale;
                    final double h = baseH * scale;
                    final double g = baseGap * scale;

                    final double radius = (4.0 * scale).clamp(3.0, 8.0);
                    final double stroke = (1.2 * scale).clamp(1.0, 2.0);
                    final double font = (20.0 * scale).clamp(16.0, 24.0);

                    final children = <Widget>[];
                    for (int idx = 0; idx < _len; idx++) {
                      children.add(SizedBox(
                        width: w,
                        height: h,
                        child: _OtpCell(
                          controller: _ctrs[idx],
                          focusNode: _nodes[idx],
                          onChanged: (v) => _onChanged(idx, v),
                          fontSize: font,
                          radius: radius,
                          stroke: stroke,
                          isError: _isError, // propagate error state
                        ),
                      ));
                      if (idx < _len - 1) {
                        children.add(SizedBox(width: idx == 2 ? g * 2 : g));
                      }
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: children,
                    );
                  },
                ),

                AppLayout.gapMD,

                Text(
                  'Enter the  $_len-digit code sent to ${widget.phoneDisplay}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),

                const SizedBox(height: 12),

                if (_statusText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _statusText!,
                      style: TextStyle(color: _statusColor),
                    ),
                  ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: (_left == 0)
                        ? () {
                            _clearAll();
                            _startTimer();
                          }
                        : null,
                    style: _resendStyle(_left == 0),
                    child: Text(
                      _left == 0 ? 'Resend code' : 'Resend code ($_left)',
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

/*  OTP Cell:
    - No border when empty & not focused
    - Has border when focused or filled
    - Hide placeholder '–' when focused/filled
    - Show red border when page in error state
*/
class _OtpCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double fontSize;
  final double radius;
  final double stroke;
  final bool isError;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.fontSize,
    required this.radius,
    required this.stroke,
    this.isError = false,
  });

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant _OtpCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_rebuild);
      widget.focusNode.addListener(_rebuild);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = widget.focusNode.hasFocus;
    final hasText = widget.controller.text.isNotEmpty;
    final active = hasFocus || hasText;

    final borderColor =
        widget.isError ? Colors.red : AppColors.brandOrange;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill50,
        borderRadius: BorderRadius.circular(widget.radius),
        border: active
            ? Border.all(color: borderColor, width: widget.stroke)
            : (widget.isError
                ? Border.all(color: borderColor, width: widget.stroke)
                : null),
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
          strutStyle: StrutStyle(
            forceStrutHeight: true,
            height: 1,
            leading: 0,
            fontSize: widget.fontSize,
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            isCollapsed: true,
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: active ? null : '–', // hide dash when focused/filled
            hintStyle: TextStyle(
              color: AppColors.placeholder,
              fontSize: widget.fontSize,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
