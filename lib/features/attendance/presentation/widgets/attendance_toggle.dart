import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AttendanceToggle extends StatelessWidget {
  const AttendanceToggle({super.key, required this.label, required this.feeDue});

  final String label;
  final bool feeDue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: AppTextStyles.body),
      subtitle: feeDue ? const Text(AppStrings.feeDue, style: AppTextStyles.link) : null,
      trailing: const Text('Present / Absent'),
    );
  }
}
