import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('ID Sports', style: AppTextStyles.heading),
            const SizedBox(height: 24),
            AppTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 12),
            AppTextField(controller: _passwordController, label: 'Password', obscureText: true),
            const SizedBox(height: 24),
            AppButton(label: 'Login', onPressed: () => context.go('/home')),
          ],
        ),
      ),
    );
  }
}
