import 'package:dio/dio.dart';
import 'package:ezsports/core/auth/auth_session.dart';
import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/features/auth/data/models/user_model.dart';
import 'package:ezsports/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({
    required this.mobile,
    this.purpose = 'signup',
    super.key,
  });

  final String mobile;
  final String purpose;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  static const int _otpLength = 6;

  late final List<TextEditingController> _digits;
  late final List<FocusNode> _focusNodes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _digits = List<TextEditingController>.generate(
      _otpLength,
      (int _) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(_otpLength, (int index) {
      final FocusNode node = FocusNode();
      node.onKeyEvent = (FocusNode _, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _digits[index].text.isEmpty &&
            index > 0) {
          _digits[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
      return node;
    });
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _digits) {
      controller.dispose();
    }
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _digits.map((TextEditingController controller) => controller.text).join();

  void _fillFrom(int start, String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return;
    }
    for (int offset = 0; offset < digits.length && start + offset < _otpLength; offset++) {
      _digits[start + offset].text = digits[offset];
    }
    final int next = (start + digits.length).clamp(0, _otpLength - 1);
    _focusNodes[next].requestFocus();
  }

  String? _homeForRole(String role) {
    switch (role) {
      case 'coach':
        return '/home';
      case 'player':
        return '/player/home';
      default:
        return null;
    }
  }

  Future<void> _verify() async {
    final String otp = _otp;
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all 6 digits.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final UserModel user = widget.purpose == 'login'
          ? await ref.read(authRepositoryProvider).verifyLoginOtp(
                mobile: widget.mobile,
                otp: otp,
              )
          : await ref.read(authRepositoryProvider).verifySignupOtp(
                mobile: widget.mobile,
                otp: otp,
              );
      final String? route = _homeForRole(user.role);
      if (route == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This code is not for a coach or player account.')),
        );
        return;
      }
      await AuthSession.save(token: user.accessToken, role: user.role);
      if (!mounted) {
        return;
      }
      if (widget.purpose != 'login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Your details are saved.')),
        );
      }
      context.go(route);
    } on DioException catch (error) {
      final Object? detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data as Map<String, dynamic>)['detail']
          : null;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail?.toString() ?? 'OTP verification failed')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.playerBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(AppIcons.back, color: AppColors.playerAccent),
                ),
                const Expanded(
                  child: Text(AppStrings.otpTitle, style: AppTextStyles.pageTitle),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 18),
              child: Text(
                '${widget.purpose == 'login' ? AppStrings.loginOtpSubtitle : AppStrings.otpSubtitle}\nSent to the mobile ending ${widget.mobile.length >= 4 ? widget.mobile.substring(widget.mobile.length - 4) : widget.mobile}',
                style: AppTextStyles.muted,
              ),
            ),
            Row(
              children: List<Widget>.generate(_otpLength, (int index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                    child: AspectRatio(
                      aspectRatio: 0.82,
                      child: TextField(
                        controller: _digits[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        autofillHints: const <String>[AutofillHints.oneTimeCode],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.playerCream,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.playerCardAlt,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.playerAccent, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.playerAccent, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.playerGold, width: 2),
                          ),
                        ),
                        onChanged: (String value) {
                          if (value.length > 1) {
                            _fillFrom(index, value);
                            return;
                          }
                          if (value.isNotEmpty && index < _otpLength - 1) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _loading ? 'Submitting…' : AppStrings.submit,
              backgroundColor: AppColors.playerAccent,
              onPressed: () {
                if (!_loading) {
                  _verify();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
