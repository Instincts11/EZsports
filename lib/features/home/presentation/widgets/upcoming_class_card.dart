import 'package:ezsports/core/widgets/session_card.dart';
import 'package:flutter/material.dart';

class UpcomingClassCard extends StatelessWidget {
  const UpcomingClassCard({super.key, required this.onViewStudents});

  final VoidCallback onViewStudents;

  @override
  Widget build(BuildContext context) {
    return SessionCard(
      title: 'Weekend Eve',
      subtitle: 'Today 3:30 - 5:00',
      onViewStudents: onViewStudents,
    );
  }
}
