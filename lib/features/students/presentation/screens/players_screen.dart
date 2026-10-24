import 'package:ezsports/core/constants/app_colors.dart';
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

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<StudentModel>> players = ref.watch(playersProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: <Widget>[
          const Text(AppStrings.players, style: AppTextStyles.pageTitle),
          const SizedBox(height: 6),
          players.maybeWhen(
            data: (List<StudentModel> roster) => Text('${roster.length} on your lists', style: AppTextStyles.muted),
            orElse: () => const Text('Players from the academy', style: AppTextStyles.muted),
          ),
          const SizedBox(height: 16),
          CoachSearchField(hint: AppStrings.findPlayer, onChanged: _onSearch),
          const SizedBox(height: 12),
          players.when(
            data: (List<StudentModel> roster) {
              final String query = _query.trim().toLowerCase();
              final List<StudentModel> visible = query.isEmpty
                  ? roster
                  : roster.where((StudentModel student) => student.name.toLowerCase().contains(query)).toList();
              if (visible.isEmpty) {
                return const Text('No players match that search.', style: AppTextStyles.muted);
              }
              final List<StudentModel> due = visible.where((StudentModel student) => student.feeDue).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (due.isNotEmpty) ...<Widget>[
                    const Text('Needs a look', style: AppTextStyles.heading),
                    const SizedBox(height: 10),
                    CreamCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: due
                            .take(4)
                            .map(
                              (StudentModel student) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  student.feeLine.isEmpty ? '${student.name} · fee due' : '${student.name} · ${student.feeLine}',
                                  style: AppTextStyles.body,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  CreamCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: visible
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
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (Object error, StackTrace stack) => const Text(
              'Sign in as a coach to load players.',
              style: AppTextStyles.muted,
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch(String value) {
    setState(() => _query = value);
  }
}
