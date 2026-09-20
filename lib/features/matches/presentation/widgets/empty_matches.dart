import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class EmptyMatches extends StatelessWidget {
  const EmptyMatches({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('No Matches!', style: AppTextStyles.title),
          const SizedBox(height: 12),
          AppButton(label: 'Create New Match', onPressed: onCreate),
        ],
      ),
    );
  }
}
