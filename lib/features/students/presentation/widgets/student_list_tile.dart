import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/fee_due_badge.dart';
import 'package:ezsports/core/widgets/initials_avatar.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:flutter/material.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile({super.key, required this.student, required this.onTap});

  final StudentModel student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: InitialsAvatar(initials: student.initials),
      title: Text(student.name, style: AppTextStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (student.feeDue) const FeeDueBadge(compact: true),
          const Icon(AppIcons.chevron, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
