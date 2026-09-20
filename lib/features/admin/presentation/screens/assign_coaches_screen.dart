import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AssignCoachesScreen extends StatelessWidget {
  const AssignCoachesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session assignments')),
      body: const Center(child: Text('Assign or move coaches per session', style: AppTextStyles.body)),
    );
  }
}
