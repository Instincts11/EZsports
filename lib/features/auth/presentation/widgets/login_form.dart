import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CoachSearchField(controller: emailController, hint: AppStrings.email, showSearchIcon: false),
        const SizedBox(height: 12),
        CoachSearchField(
          controller: passwordController,
          hint: AppStrings.password,
          showSearchIcon: false,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        AppButton(label: AppStrings.loginAction, onPressed: onSubmit),
      ],
    );
  }
}
