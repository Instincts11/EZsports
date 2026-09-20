import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class ClassesReportScreen extends StatelessWidget {
  const ClassesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes Report')),
      body: const Center(child: Text('Report view of the same session data', style: AppTextStyles.body)),
    );
  }
}
