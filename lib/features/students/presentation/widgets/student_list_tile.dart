import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile({super.key, required this.name, required this.feeDue});

  final String name;
  final bool feeDue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: AppTextStyles.body),
      trailing: feeDue
          ? const Text('Fee Due', style: TextStyle(color: AppColors.danger))
          : null,
    );
  }
}
