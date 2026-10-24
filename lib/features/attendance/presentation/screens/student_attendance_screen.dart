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
import 'package:ezsports/features/attendance/providers/attendance_providers.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/classes/providers/classes_providers.dart';
import 'package:ezsports/features/home/providers/home_providers.dart';
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
  bool _seeded = false;
  bool _saving = false;

  void _seed(List<StudentModel> players) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    for (final StudentModel student in players) {
      if (student.attendanceStatus == 'present') {
        _presentIds.add(student.studentId);
      }
    }
  }

  Future<void> _save(List<StudentModel> players) async {
    setState(() => _saving = true);
    try {
      for (final StudentModel student in players) {
        await ref.read(attendanceRepositoryProvider).markStudentAttendance(
          sessionId: widget.sessionId,
          studentId: student.studentId,
          status: _presentIds.contains(student.studentId) ? 'present' : 'absent',
        );
      }
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(sessionRosterProvider(widget.sessionId));
      if (mounted) {
        context.go('/sessions');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance could not be saved.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<StudentModel>> roster = ref.watch(sessionRosterProvider(widget.sessionId));
    final SessionModel? session = ref.watch(sessionsProvider).maybeWhen(
      data: (List<SessionModel> items) {
        for (final SessionModel item in items) {
          if (item.sessionId == widget.sessionId) {
            return item;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final String subtitle = session == null
        ? 'Loading this session'
        : '${session.dateLabel} · ${session.timeRange} · ${session.studentCount} players';
    final List<StudentModel> players = roster.maybeWhen(
      data: (List<StudentModel> items) => items,
      orElse: () => const <StudentModel>[],
    );
    if (roster.hasValue) {
      _seed(players);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/sessions'),
          icon: const Icon(AppIcons.back, color: AppColors.primary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(AppStrings.markAttendance, style: AppTextStyles.titleOnDark),
            Text(subtitle, style: AppTextStyles.caption),
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
            child: roster.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (Object error, StackTrace stack) => const Center(
                child: Text('This session roster could not be loaded.', style: AppTextStyles.muted),
              ),
              data: (List<StudentModel> loaded) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
              children: <Widget>[
                if (loaded.isEmpty)
                  const Text('No players are on this session.', style: AppTextStyles.muted)
                else
                CreamCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: loaded
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
                            subtitle: student.skipReason.isNotEmpty
                                ? Text('Skipping: ${student.skipReason}', style: AppTextStyles.muted)
                                : student.checkedIn
                                    ? const Text('Checked in', style: AppTextStyles.muted)
                                    : null,
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
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: AppButton(
              label: _saving ? 'Saving…' : AppStrings.saveMarks,
              onPressed: () {
                if (players.isEmpty || _saving) {
                  return;
                }
                _save(players);
              },
            ),
          ),
        ],
      ),
    );
  }
}
