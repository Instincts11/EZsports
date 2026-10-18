import 'package:dio/dio.dart';
import 'package:ezsports/core/auth/auth_session.dart';
import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/brand_mark.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/features/auth/data/models/otp_request_model.dart';
import 'package:ezsports/features/auth/data/models/user_model.dart';
import 'package:ezsports/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_onIdentifierChanged);
  }

  void _onIdentifierChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _identifierController.removeListener(_onIdentifierChanged);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _homeForRole(String role) {
    switch (role) {
      case 'coach':
        return '/home';
      case 'player':
        return '/player/home';
      case 'super_admin':
      case 'accountant':
        return '/admin';
      default:
        return null;
    }
  }

  bool _isEmail(String value) => value.contains('@');

  Future<void> _sendLoginOtp(String mobile) async {
    setState(() => _loading = true);
    try {
      final OtpRequestModel result = await ref.read(authRepositoryProvider).requestLoginOtp(mobile);
      if (!mounted) {
        return;
      }
      final String? token = result.accessToken;
      if (token != null && token.isNotEmpty) {
        final String? route = _homeForRole(result.role ?? '');
        if (route == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This mobile is not a coach or player account.')),
          );
          return;
        }
        await AuthSession.save(token: token, role: result.role ?? '');
        if (!mounted) {
          return;
        }
        context.go(route);
        return;
      }
      context.push(
        '/signup/otp',
        extra: <String, String>{
          'mobile': result.mobile,
          'purpose': 'login',
        },
      );
    } on DioException catch (error) {
      final Object? detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data as Map<String, dynamic>)['detail']
          : null;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail?.toString() ?? 'Could not send OTP. Is the API running?')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _login() async {
    final String identifier = _identifierController.text.trim();
    final String password = _passwordController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email or mobile number.')),
      );
      return;
    }
    if (!_isEmail(identifier)) {
      await _sendLoginOtp(identifier);
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your password.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final UserModel user = await ref.read(authRepositoryProvider).login(
            identifier: identifier,
            password: password,
          );
      final String? route = _homeForRole(user.role);
      if (route == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This account cannot sign in here.')),
        );
        return;
      }
      await AuthSession.save(token: user.accessToken, role: user.role);
      if (!mounted) {
        return;
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
        SnackBar(content: Text(detail?.toString() ?? 'Login failed. Is the API running?')),
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const SizedBox(height: 40),
            const BrandMark(),
            const SizedBox(height: 16),
            const Text(AppStrings.loginTitle, style: AppTextStyles.pageTitle),
            const Text(AppStrings.academyName, style: AppTextStyles.academySubtitle),
            const SizedBox(height: 36),
            CoachSearchField(
              hint: AppStrings.emailOrMobile,
              controller: _identifierController,
              showSearchIcon: false,
              autofillHints: const <String>[AutofillHints.email],
            ),
            if (_identifierController.text.contains('@')) ...<Widget>[
              const SizedBox(height: 12),
              CoachSearchField(
                hint: AppStrings.password,
                controller: _passwordController,
                showSearchIcon: false,
                obscureText: true,
                autofillHints: const <String>[AutofillHints.password],
              ),
            ],
            const SizedBox(height: 28),
            AppButton(
              label: _loading
                  ? 'Please wait…'
                  : (_identifierController.text.contains('@') ? AppStrings.loginAction : AppStrings.sendOtp),
              onPressed: () {
                if (!_loading) {
                  _login();
                }
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: const Text(
                AppStrings.signUpAsPlayer,
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.playerAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
