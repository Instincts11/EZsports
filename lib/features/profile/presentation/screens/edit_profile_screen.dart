import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Information')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text('Name, DOB, gender, mobile, emergency, email, certifications, experience, address', style: AppTextStyles.body),
            const SizedBox(height: 24),
            AppButton(label: 'Save', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
