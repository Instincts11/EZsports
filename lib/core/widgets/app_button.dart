import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
      child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.surface)),
    );
  }
}
