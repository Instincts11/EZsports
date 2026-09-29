import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/presentation/widgets/student_list_tile.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BatchRosterScreen extends ConsumerWidget {
  const BatchRosterScreen({super.key, required this.batchId});

  final int batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BatchModel? batch = ref.watch(batchByIdProvider(batchId));
    final List<StudentModel> players = ref.watch(demoPlayersProvider);
    final String title = batch?.name ?? AppStrings.batches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/batches'),
          icon: const Icon(AppIcons.back, color: AppColors.primary),
        ),
        title: Column(
          children: <Widget>[
            Text(title, style: AppTextStyles.titleOnDark),
            Text('${batch?.days ?? ''} · ${players.length} players', style: AppTextStyles.caption),
          ],
        ),
        actions: const <Widget>[
          Icon(AppIcons.calendar, color: AppColors.primary),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: <Widget>[
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
