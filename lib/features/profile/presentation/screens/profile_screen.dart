import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/profile/presentation/screens/coach_attendance_history_screen.dart';
import 'package:ezsports/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:ezsports/features/profile/presentation/screens/my_leaves_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: <Widget>[
          const ListTile(title: Text('Coach', style: AppTextStyles.title), subtitle: Text('ID Sports Academy')),
          ListTile(
            title: const Text('My Information'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
            ),
          ),
          ListTile(
            title: const Text('My Attendance'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CoachAttendanceHistoryScreen()),
            ),
          ),
          ListTile(
            title: const Text('My Leaves'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyLeavesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
