import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/home/presentation/widgets/attendance_rings.dart';
import 'package:ezsports/features/home/presentation/widgets/check_in_button.dart';
import 'package:ezsports/features/home/presentation/widgets/matches_strip.dart';
import 'package:ezsports/features/home/presentation/widgets/upcoming_class_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('ID Sports Academy', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          const AttendanceRings(),
          const SizedBox(height: 12),
          CheckInButton(onPressed: () {}),
          const SizedBox(height: 12),
          UpcomingClassCard(onViewStudents: () => context.go('/classes')),
          const SizedBox(height: 12),
          MatchesStrip(onOpenMatches: () => context.go('/matches')),
        ],
      ),
    );
  }
}
