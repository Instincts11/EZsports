import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class MyLeavesScreen extends StatelessWidget {
  const MyLeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Leaves')),
      body: const Center(child: Text('Leave requests', style: AppTextStyles.body)),
    );
  }
}
