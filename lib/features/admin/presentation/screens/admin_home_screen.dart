import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/admin/presentation/screens/assign_accountant_screen.dart';
import 'package:ezsports/features/admin/presentation/screens/assign_coaches_screen.dart';
import 'package:ezsports/features/admin/presentation/screens/manage_batches_screen.dart';
import 'package:ezsports/features/admin/presentation/screens/manage_people_screen.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin')),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Academy setup', style: AppTextStyles.title),
          ),
          ListTile(
            title: const Text('People'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ManagePeopleScreen())),
          ),
          ListTile(
            title: const Text('Batches'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ManageBatchesScreen())),
          ),
          ListTile(
            title: const Text('Assign accountant'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AssignAccountantScreen())),
          ),
          ListTile(
            title: const Text('Assign coaches to sessions'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AssignCoachesScreen())),
          ),
        ],
      ),
    );
  }
}
