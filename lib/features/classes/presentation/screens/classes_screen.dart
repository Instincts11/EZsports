import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/date_range_filter.dart';
import 'package:ezsports/features/classes/presentation/screens/classes_report_screen.dart';
import 'package:ezsports/features/classes/presentation/widgets/class_session_card.dart';
import 'package:flutter/material.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ClassesReportScreen()),
              );
            },
            icon: const Icon(Icons.grid_view),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          DateRangeFilter(label: 'Select date range', onTap: _noop),
          SizedBox(height: 12),
          Text('Upcoming', style: AppTextStyles.title),
          ClassSessionCard(),
        ],
      ),
    );
  }
}

void _noop() {}
