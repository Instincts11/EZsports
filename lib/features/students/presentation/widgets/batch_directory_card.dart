import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class BatchDirectoryCard extends StatelessWidget {
  const BatchDirectoryCard({
    super.key,
    required this.name,
    required this.count,
    required this.onTap,
  });

  final String name;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: AppTextStyles.title),
      subtitle: Text('$count students', style: AppTextStyles.caption),
      onTap: onTap,
    );
  }
}
