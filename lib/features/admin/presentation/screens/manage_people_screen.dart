import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class ManagePeopleScreen extends StatelessWidget {
  const ManagePeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coaches & Students')),
      body: const Center(child: Text('Create coaches and students under Super Admin', style: AppTextStyles.body)),
    );
  }
}
