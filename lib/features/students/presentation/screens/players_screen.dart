import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/presentation/widgets/student_list_tile.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<StudentModel> players = ref.watch(demoPlayersProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: <Widget>[
          const Text(AppStrings.players, style: AppTextStyles.pageTitle),
          const SizedBox(height: 6),
          Text('${players.length} on your lists · fee due and trials first', style: AppTextStyles.muted),
          const SizedBox(height: 16),
          const Text('Needs a look', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Advaita S · Weekend Evening', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('September fee is open. Missed 30 Aug with no note. Speak to her before the 3v2.', style: AppTextStyles.body),
                SizedBox(height: 14),
                Text('Ishant Jay · Weekend Evening', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('Ankle from 30 Aug. Jog and pass only. Keep him out of shooting and the games.', style: AppTextStyles.body),
                SizedBox(height: 14),
                Text('Abner Lino · Weekend Evening', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('Fee due, and no check-in for three weeks. Call the parent if he misses today.', style: AppTextStyles.body),
                SizedBox(height: 14),
                Text('Diya P · trial', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('Bib 16 tonight. Father Pranav collects her. Decide by Wednesday whether she joins the group.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const CoachSearchField(hint: AppStrings.findPlayer),
          const SizedBox(height: 12),
          CreamCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: players
                  .map(
                    (StudentModel student) => StudentListTile(
                      student: student,
                      onTap: () => context.go('/players/${student.studentId}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
