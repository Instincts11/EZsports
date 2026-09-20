import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AttendanceRings extends StatelessWidget {
  const AttendanceRings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Days', style: AppTextStyles.caption),
        Text('Attended', style: AppTextStyles.caption),
        Text('Missed', style: AppTextStyles.caption),
      ],
    );
  }
}
