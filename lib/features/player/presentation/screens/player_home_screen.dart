import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/presentation/screens/player_profile_screen.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:ezsports/features/player/providers/player_home_providers.dart';
import 'package:ezsports/features/player/providers/player_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerHomeScreen extends ConsumerStatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  ConsumerState<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends ConsumerState<PlayerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshPlayerDraft(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PlayerHomeModel> home = ref.watch(playerHomeProvider);
    final String draftName = ref.watch(playerDraftProvider).name;
    return SafeArea(
      bottom: false,
      child: home.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.playerAccent)),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(playerLoadMessage(error), style: AppTextStyles.bodyOnDark, textAlign: TextAlign.center),
          ),
        ),
        data: (PlayerHomeModel data) {
          final String playerName = data.playerName.isNotEmpty ? data.playerName : draftName;
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('ID SPORTS', style: AppTextStyles.overline),
                        Text(playerName.isEmpty ? 'Player' : playerName, style: AppTextStyles.displayName),
                        const SizedBox(height: 4),
                        Text(data.academyName, style: const TextStyle(color: AppColors.playerGold, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  _NotificationButton(count: _noticeCount(data)),
                ],
              ),
              const SizedBox(height: 14),
              _HomeHeader(data: data),
              if (data.notice.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                _NoticeCard(kicker: 'ACADEMY', title: data.academyName, body: data.notice.trim()),
              ],
              if (data.phone.trim().isNotEmpty || data.address.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                _NoticeCard(
                  kicker: 'CONTACT',
                  title: data.phone.trim().isEmpty ? data.academyName : data.phone.trim(),
                  body: data.address.trim().isEmpty ? 'Academy contact' : data.address.trim(),
                ),
              ],
              if (data.todaySessions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 22),
                const Text('Notification', style: AppTextStyles.heading),
                const SizedBox(height: 10),
                _NoticeCard(
                  kicker: 'TODAY',
                  title: '${data.todaySessions.first.session.batchName} · ${data.todaySessions.first.session.timeRange}',
                  body: data.todaySessions.first.detail.isEmpty
                      ? 'Your session is on the schedule for today.'
                      : data.todaySessions.first.detail,
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  const Expanded(child: Text('My attendance', style: AppTextStyles.heading)),
                  Text(formatApiDate(data.date), style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 10),
              CreamCard(
                color: AppColors.playerCream,
                child: Row(
                  children: <Widget>[
                    Expanded(child: AttendanceRing(value: data.days, label: 'Days', color: AppColors.playerAccent, progress: _share(data.days, data.days))),
                    Expanded(child: AttendanceRing(value: data.attended, label: 'Attended', color: AppColors.playerAmber, progress: _share(data.attended, data.days))),
                    Expanded(child: AttendanceRing(value: data.missed, label: 'Missed', color: AppColors.playerCoral, progress: _share(data.missed, data.days))),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('Today', style: AppTextStyles.heading),
              const SizedBox(height: 10),
              if (data.todaySessions.isEmpty)
                const Text('No session today.', style: AppTextStyles.caption)
              else
                ...data.todaySessions.map(
                  (PlayerSessionModel session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SessionCard(session: session),
                  ),
                ),
              const SizedBox(height: 12),
              PlayerSectionTitle(
                'Upcoming sessions',
                action: 'See schedule ›',
                onAction: () => context.go('/player/schedule'),
              ),
              const SizedBox(height: 10),
              if (data.upcomingSessions.isEmpty)
                const Text('No upcoming sessions.', style: AppTextStyles.caption)
              else
                ...data.upcomingSessions.map(
                  (PlayerSessionModel session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SessionTile(
                      date: session.session.dateLabel,
                      time: session.session.timeRange,
                      batch: session.session.batchName,
                      detail: session.detail,
                      pitch: session.session.ground,
                    ),
                  ),
                ),
              if (data.matches.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                PlayerSectionTitle(
                  'Next fixture',
                  action: 'See fixtures ›',
                  onAction: () => context.go('/player/batches'),
                ),
                const SizedBox(height: 10),
                _NoticeCard(
                  kicker: 'FIXTURE',
                  title: data.matches.first.opponentLabel,
                  body: <String>[
                    data.matches.first.kickoff,
                    if (data.matches.first.venue.isNotEmpty) data.matches.first.venue,
                    if (data.matches.first.result.isNotEmpty) data.matches.first.result,
                    if (data.matches.first.venue.isEmpty && data.matches.first.batchName.isNotEmpty) data.matches.first.batchName,
                  ].join(' · '),
                ),
              ],
              if (data.feeAmount != null) ...<Widget>[
                const SizedBox(height: 22),
                const Text('Fees', style: AppTextStyles.heading),
                const SizedBox(height: 10),
                CreamCard(
                  color: AppColors.playerCream,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '₹${data.feeAmount} · ${data.feeStatus}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk),
                      ),
                      if (data.feeDueDate != null && data.feeDueDate!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text('Due ${formatApiDate(data.feeDueDate)}', style: const TextStyle(color: Color(0xFF5C564E))),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

double _share(int part, int total) {
  if (total <= 0) {
    return 0;
  }
  return part / total;
}

int _noticeCount(PlayerHomeModel data) {
  final String fee = data.feeStatus.toLowerCase();
  final int feeNotice = fee == 'due' || fee == 'overdue' ? 1 : 0;
  return data.todaySessions.length + data.matches.length + feeNotice;
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => showPlayerNotifications(context),
      icon: Badge(
        isLabelVisible: true,
        backgroundColor: AppColors.playerCoral,
        label: Text('$count'),
        child: const Icon(AppIcons.notifications, color: AppColors.playerGold),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.data});

  final PlayerHomeModel data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerSessionModel? current = data.todaySessions.where((PlayerSessionModel row) => !row.skipped).firstOrNull;
    final DateTime now = DateTime.now();
    final Widget date = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_clock(now), style: AppTextStyles.bodyOnDark),
          Text(formatApiDate(data.date), style: AppTextStyles.caption),
        ],
      ),
    );
    final Widget sessions = Column(
      children: <Widget>[
        Text('${data.sessionsToday}', style: const TextStyle(fontSize: 28, height: 1, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
        const Text('Sessions', style: AppTextStyles.caption),
      ],
    );
    return Row(
      children: <Widget>[
        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.playerMuted),
        const SizedBox(width: 8),
        date,
        sessions,
        if (current != null) ...<Widget>[
          const SizedBox(width: 10),
          CheckInButton(
            checked: current.checkedIn,
            onPressed: () => _saveResponse(
              context,
              () => respondToSession(ref, current.session.sessionId, checkedIn: !current.checkedIn),
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> _saveResponse(BuildContext context, Future<void> Function() save) async {
  try {
    await save();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Check your connection and try again.')),
      );
    }
  }
}

String _clock(DateTime now) {
  final String suffix = now.hour >= 12 ? 'PM' : 'AM';
  int hour = now.hour % 12;
  if (hour == 0) {
    hour = 12;
  }
  return '$hour:${now.minute.toString().padLeft(2, '0')} $suffix';
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});

  final PlayerSessionModel session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SessionTile(
      date: session.session.dateLabel,
      time: session.session.timeRange,
      batch: session.session.batchName,
      detail: session.detail,
      pitch: session.session.ground,
      borderColor: session.skipped ? AppColors.playerCoral : AppColors.playerAccent,
      badge: sessionBadge(session),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (session.skipped)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Noted: ${session.skipReason}',
                style: const TextStyle(color: AppColors.playerCoral, fontWeight: FontWeight.w700),
              ),
            ),
          TextButton(
            onPressed: () => skipOrUndoSession(context, ref, session, session.session.timeRange),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.playerCoral,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(session.skipped ? 'Undo skip' : 'Skip session', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.kicker, required this.title, required this.body});

  final String kicker;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      color: AppColors.playerCream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            kicker,
            style: const TextStyle(
              color: AppColors.playerGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: Color(0xFF5C564E), height: 1.35)),
        ],
      ),
    );
  }
}
