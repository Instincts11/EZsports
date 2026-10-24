import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/home/data/models/home_dashboard_model.dart';
import 'package:ezsports/features/home/presentation/widgets/home_header.dart';
import 'package:ezsports/features/home/presentation/widgets/home_session_card.dart';
import 'package:ezsports/features/home/presentation/widgets/sessions_summary_card.dart';
import 'package:ezsports/features/home/providers/home_providers.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeDashboardModel> dashboard = ref.watch(homeDashboardProvider);
    final AsyncValue<List<StudentModel>> players = ref.watch(playersProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 12, AppSizes.screenPadding, 28),
        children: <Widget>[
          const HomeHeader(),
          const SizedBox(height: 18),
          dashboard.when(
            data: (HomeDashboardModel home) => SessionsSummaryCard(
              count: home.sessionsToday,
              dateLabel: home.dateLabel,
              session: home.upcomingSessions.firstOrNull,
            ),
            loading: () => const SessionsSummaryCard(count: 0, dateLabel: 'Loading today'),
            error: (Object error, StackTrace stack) => const SessionsSummaryCard(count: 0, dateLabel: 'Could not load today'),
          ),
          const SizedBox(height: 14),
          dashboard.maybeWhen(
            data: (HomeDashboardModel home) {
              final bool hasNotice = home.notice.trim().isNotEmpty;
              final bool hasPhone = home.phone.trim().isNotEmpty;
              final bool hasAddress = home.address.trim().isNotEmpty;
              if (!hasNotice && !hasPhone && !hasAddress) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: CreamCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (hasNotice) ...<Widget>[
                        const Text('Academy notice', style: AppTextStyles.title),
                        const SizedBox(height: 6),
                        Text(home.notice.trim(), style: AppTextStyles.body),
                      ],
                      if (hasPhone) ...<Widget>[
                        if (hasNotice) const SizedBox(height: 8),
                        Text(home.phone.trim(), style: AppTextStyles.body),
                      ],
                      if (hasAddress) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(home.address.trim(), style: AppTextStyles.muted),
                      ],
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const CoachSearchField(hint: AppStrings.searchPlayers),
          const SizedBox(height: 22),
          _SectionTitle(
            AppStrings.todaysSessions,
            action: AppStrings.viewAllSessions,
            onAction: () => context.go('/sessions'),
          ),
          dashboard.when(
            data: (HomeDashboardModel home) {
              if (home.upcomingSessions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('No sessions assigned to you today.', style: AppTextStyles.muted),
                );
              }
              return Column(
                children: home.upcomingSessions
                    .map(
                      (SessionModel session) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HomeSessionCard(
                          session: session,
                          onOpenRoster: () => _openRoster(context, session),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (Object error, StackTrace stack) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Sign in as a coach to load today’s sessions.', style: AppTextStyles.muted),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Needs you', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          dashboard.maybeWhen(
            data: (HomeDashboardModel home) {
              final SessionModel? session = home.upcomingSessions.where((SessionModel row) => row.attendanceOpen).firstOrNull;
              if (session == null) {
                return const SizedBox.shrink();
              }
              return CreamCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Attendance still open', style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(
                      '${session.batchName} · ${session.studentsMarked} of ${session.studentCount} players marked · ${session.start}',
                      style: AppTextStyles.muted,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/sessions/${session.sessionId}/attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: const Text(AppStrings.markAttendance, style: AppTextStyles.button),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          players.maybeWhen(
            data: (List<StudentModel> roster) {
              final List<StudentModel> due = roster.where((StudentModel student) => student.feeDue).toList();
              if (due.isEmpty) {
                return const SizedBox.shrink();
              }
              return CreamCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${due.length} players with fees open', style: AppTextStyles.title),
                    const SizedBox(height: 8),
                    ...due.take(4).map(
                      (StudentModel student) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          student.feeLine.isEmpty ? '${student.name} · ${student.parentMobile}' : '${student.name} · ${student.feeLine}',
                          style: AppTextStyles.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => context.go('/players'),
                      child: const Row(
                        children: <Widget>[
                          Text('Open profiles', style: AppTextStyles.link),
                          SizedBox(width: 2),
                          Icon(AppIcons.forward, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

void _openRoster(BuildContext context, SessionModel session) {
  final int? batchId = session.batchId;
  if (batchId == null) {
    context.go('/players');
    return;
  }
  context.go('/batches/$batchId');
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(text, style: AppTextStyles.heading)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(action!, style: AppTextStyles.link),
          ),
      ],
    );
  }
}
