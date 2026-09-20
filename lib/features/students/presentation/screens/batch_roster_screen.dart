import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/students/presentation/widgets/student_list_tile.dart';
import 'package:flutter/material.dart';

class BatchRosterScreen extends StatelessWidget {
  const BatchRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch roster')),
      body: ListView(
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Enrolled students', style: AppTextStyles.title),
          ),
          StudentListTile(name: 'Arjun Menon', feeDue: true),
        ],
      ),
    );
  }
}
