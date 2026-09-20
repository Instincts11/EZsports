import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onViewStudents,
  });

  final String title;
  final String subtitle;
  final VoidCallback onViewStudents;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: AppTextStyles.title),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: TextButton(onPressed: onViewStudents, child: const Text('View Students')),
      ),
    );
  }
}
