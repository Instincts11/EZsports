import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/attendance/presentation/widgets/attendance_toggle.dart';
import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark attendance #$sessionId')),
      body: ListView(
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Session roster', style: AppTextStyles.title),
          ),
          AttendanceToggle(label: 'Arjun Menon', feeDue: true),
        ],
      ),
    );
  }
}
