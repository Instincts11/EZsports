import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class CreateBillScreen extends StatelessWidget {
  const CreateBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create bill')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text('Amount, due date, status — Accountant only', style: AppTextStyles.body),
            const SizedBox(height: 24),
            AppButton(label: 'Save bill', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
