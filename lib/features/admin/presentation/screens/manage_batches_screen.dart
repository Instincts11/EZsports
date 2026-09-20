import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class ManageBatchesScreen extends StatelessWidget {
  const ManageBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: const Center(child: Text('Create academy sports and batches', style: AppTextStyles.body)),
    );
  }
}
