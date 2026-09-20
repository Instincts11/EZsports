import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Match')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text('Fixture uses the same time language as a session', style: AppTextStyles.body),
            const SizedBox(height: 24),
            AppButton(label: 'Save match', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
