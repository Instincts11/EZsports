import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/app_text_field.dart';
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
        AppTextField(controller: emailController, label: 'Email'),
        const SizedBox(height: 12),
        AppTextField(controller: passwordController, label: 'Password', obscureText: true),
        const SizedBox(height: 24),
        AppButton(label: 'Login', onPressed: onSubmit),
      ],
    );
  }
}
