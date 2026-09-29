import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/classes/providers/classes_providers.dart';
import 'package:ezsports/features/home/presentation/widgets/home_header.dart';
import 'package:ezsports/features/home/presentation/widgets/home_session_card.dart';
import 'package:ezsports/features/home/presentation/widgets/sessions_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SessionModel> sessions = ref.watch(demoTodaySessionsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 12, AppSizes.screenPadding, 28),
        children: <Widget>[
          const HomeHeader(),
          const SizedBox(height: 18),
          SessionsSummaryCard(count: sessions.length, dateLabel: AppStrings.todayDate),
          const SizedBox(height: 14),
          const CoachSearchField(hint: AppStrings.searchPlayers),
          const SizedBox(height: 22),
          _SectionTitle(
            AppStrings.todaysSessions,
            action: AppStrings.viewAllSessions,
            onAction: () => context.go('/sessions'),
          ),
          ...sessions.map(
            (SessionModel session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HomeSessionCard(
                session: session,
                onOpenRoster: () => _openRoster(context, session),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Needs you', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Attendance still open', style: AppTextStyles.title),
                const SizedBox(height: 4),
                const Text('Weekend Evening · 15 players · 3:30 PM', style: AppTextStyles.muted),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/sessions/2/attendance'),
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
          ),
          const SizedBox(height: 12),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Two players absent last Sunday', style: AppTextStyles.title),
                const SizedBox(height: 8),
                const Text('A. Menon · Weekend Evening', style: AppTextStyles.muted),
                const Text('K. Iyer · Weekend Evening', style: AppTextStyles.muted),
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
          ),
          const SizedBox(height: 22),
          const Text(
            'PITCH PLAN',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Pitch B for both weekend groups', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Morning 7:00, evening 3:30. Cones out by 6:40 AM. Showers are due after 4. Keep the evening group on Pitch B unless the groundsman closes it.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('8 fees still open in Weekend Evening', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text('Due 10 Sep. Training is not stopped this week. Collect names before you leave tonight.', style: AppTextStyles.body),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.go('/players'),
                  child: const Row(
                    children: <Widget>[
                      Text('Open the due list', style: AppTextStyles.link),
                      SizedBox(width: 2),
                      Icon(AppIcons.forward, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Ishant Jay · light work only', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Rolled ankle on 30 Aug. Cleared to jog and pass. No shooting and no 3v2 until next Sunday.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Trial today · Diya P', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Age 12. Bib 16 with Weekend Evening. Father Pranav is on the gate list. She is not Meera’s child.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Session aims', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Morning · Weekend Morning', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('Rondo in two grids so 107 players are not standing. Cones off the wet wing.', style: AppTextStyles.body),
                SizedBox(height: 12),
                Text('Evening · Weekend Evening', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('Half-turn receive, then 3v2. Advaita starts as the extra attacker. Ishant stays out of the games.', style: AppTextStyles.body),
                SizedBox(height: 12),
                Text('If you are late', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('Assistant coach Anju starts the rondo. Do not cancel the group.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Kit already at Pitch B', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('12 bibs, 8 balls, 2 mini goals. The pump is in the kit room, not in the shed.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Saturday 12 Sep · parent chat', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('9:15 AM outside the Pitch B shed, after Weekend Morning. Topic is the 27 Sep friendly against Kochi Youth.', style: AppTextStyles.body),
              ],
            ),
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
