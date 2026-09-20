import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/attendance/presentation/widgets/attendance_toggle.dart';
import 'package:flutter/material.dart';

class CoachAttendanceScreen extends StatelessWidget {
  const CoachAttendanceScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coach attendance #$sessionId')),
      body: ListView(
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Assigned coaches', style: AppTextStyles.title),
          ),
          AttendanceToggle(label: 'Amal Coach', feeDue: false),
        ],
      ),
    );
  }
}
