import 'package:ezsports/core/widgets/session_card.dart';
import 'package:flutter/material.dart';

class ClassSessionCard extends StatelessWidget {
  const ClassSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionCard(
      title: 'Weekend Eve',
      subtitle: '15 students',
      onViewStudents: () {},
    );
  }
}
