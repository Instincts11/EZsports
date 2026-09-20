import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class DateRangeFilter extends StatelessWidget {
  const DateRangeFilter({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label, style: AppTextStyles.caption), onPressed: onTap);
  }
}
