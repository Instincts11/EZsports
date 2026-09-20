import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class MatchesStrip extends StatelessWidget {
  const MatchesStrip({super.key, required this.onOpenMatches});

  final VoidCallback onOpenMatches;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Matches', style: AppTextStyles.title),
      trailing: TextButton(onPressed: onOpenMatches, child: const Text('View')),
    );
  }
}
