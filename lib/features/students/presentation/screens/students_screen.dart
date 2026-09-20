import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/students/presentation/screens/batch_roster_screen.dart';
import 'package:ezsports/features/students/presentation/widgets/batch_directory_card.dart';
import 'package:flutter/material.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Students')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('Directory by batch', style: AppTextStyles.title),
          BatchDirectoryCard(
            name: 'Weekend Eve',
            count: 15,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BatchRosterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
