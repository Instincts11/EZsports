import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CoachAttendanceHistoryScreen extends StatelessWidget {
  const CoachAttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: const Center(child: Text('Days / Attended / Missed', style: AppTextStyles.body)),
    );
  }
}
