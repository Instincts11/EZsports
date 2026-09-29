import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/core/widgets/fee_due_badge.dart';
import 'package:ezsports/core/widgets/initials_avatar.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  final Set<int> _presentIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final List<StudentModel> players = ref.watch(demoPlayersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/sessions'),
          icon: const Icon(AppIcons.back, color: AppColors.primary),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppStrings.markAttendance, style: AppTextStyles.titleOnDark),
            Text(AppStrings.attendanceSubtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(AppSizes.screenPadding),
            child: CoachSearchField(hint: AppStrings.searchPlayers),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
              children: <Widget>[
                CreamCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: players
                        .map(
                          (StudentModel student) => ListTile(
                            leading: InitialsAvatar(initials: student.initials),
                            title: Row(
                              children: <Widget>[
                                Flexible(child: Text(student.name, style: AppTextStyles.body)),
                                if (student.feeDue) ...<Widget>[
                                  const SizedBox(width: 8),
                                  const FeeDueBadge(compact: true),
                                ],
                              ],
                            ),
                            trailing: Icon(
                              _presentIds.contains(student.studentId) ? AppIcons.radioOn : AppIcons.radioOff,
                              color: AppColors.primary,
                            ),
                            onTap: () {
                              setState(() {
                                if (_presentIds.contains(student.studentId)) {
                                  _presentIds.remove(student.studentId);
                                } else {
                                  _presentIds.add(student.studentId);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: AppButton(
              label: AppStrings.saveMarks,
              onPressed: () => context.go('/sessions'),
            ),
          ),
        ],
      ),
    );
  }
}
