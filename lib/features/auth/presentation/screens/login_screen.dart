import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/brand_mark.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'coach@idsports.com');
  final TextEditingController _passwordController = TextEditingController(text: 'coach123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            CoachSearchField(hint: AppStrings.email, controller: _emailController, showSearchIcon: false),
            const SizedBox(height: 12),
            CoachSearchField(
              hint: AppStrings.password,
              controller: _passwordController,
              showSearchIcon: false,
              obscureText: true,
            ),
            const SizedBox(height: 28),
            AppButton(
              label: AppStrings.continueAsPlayer,
              backgroundColor: AppColors.playerAccent,
              onPressed: () => context.go('/player/home'),
            ),
            const SizedBox(height: 12),
            AppButton(label: AppStrings.continueAsCoach, onPressed: () => context.go('/home')),
          ],
        ),
      ),
    );
  }
}
