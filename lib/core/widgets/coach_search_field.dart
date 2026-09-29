import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CoachSearchField extends StatelessWidget {
  const CoachSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.showSearchIcon = true,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool showSearchIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: AppTextStyles.bodyOnDark,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.muted,
        prefixIcon: showSearchIcon ? const Icon(AppIcons.search, color: AppColors.textMuted) : null,
        filled: true,
        fillColor: AppColors.searchField,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.searchRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
