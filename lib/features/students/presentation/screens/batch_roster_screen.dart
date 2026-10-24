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
    final AsyncValue<List<BatchModel>> batches = ref.watch(batchesProvider);
    final AsyncValue<List<StudentModel>> roster = ref.watch(batchRosterProvider(batchId));
    final BatchModel? batch = batches.maybeWhen(
      data: (List<BatchModel> items) {
        for (final BatchModel item in items) {
          if (item.batchId == batchId) {
            return item;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final int playerCount = roster.maybeWhen(data: (List<StudentModel> items) => items.length, orElse: () => 0);
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
            Text(
              <String>[
                if ((batch?.days ?? '').isNotEmpty) batch!.days,
                if ((batch?.meetingPoint ?? '').isNotEmpty) 'Meet at ${batch!.meetingPoint}',
                if ((batch?.kit ?? '').isNotEmpty) 'Kit: ${batch!.kit}',
                '$playerCount players',
              ].join(' · '),
              style: AppTextStyles.caption,
            ),
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
          roster.when(
            data: (List<StudentModel> players) {
              if (players.isEmpty) {
                return const Text('No players are enrolled in this batch.', style: AppTextStyles.muted);
              }
              return CreamCard(
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
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (Object error, StackTrace stack) => const Text(
              'This roster could not be loaded.',
              style: AppTextStyles.muted,
            ),
          ),
        ],
      ),
    );
  }
}
