import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
      child: Text('Check-in', style: AppTextStyles.body.copyWith(color: AppColors.surface)),
    );
  }
}
