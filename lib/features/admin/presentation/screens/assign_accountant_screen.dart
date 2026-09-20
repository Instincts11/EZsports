import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AssignAccountantScreen extends StatelessWidget {
  const AssignAccountantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Accountant')),
      body: const Center(child: Text('Finance role only — bills, no ops', style: AppTextStyles.body)),
    );
  }
}
