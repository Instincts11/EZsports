import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:ezsports/features/player/providers/player_home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerScheduleScreen extends ConsumerStatefulWidget {
  const PlayerScheduleScreen({super.key});

  @override
  ConsumerState<PlayerScheduleScreen> createState() => _PlayerScheduleScreenState();
}

class _PlayerScheduleScreenState extends ConsumerState<PlayerScheduleScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<PlayerSessionModel>> sessions = ref.watch(playerSessionsProvider);
    final DateTime today = DateTime.now();
    final DateTime start = DateTime(today.year, today.month, today.day);
    final List<DateTime> days = List<DateTime>.generate(7, (int index) => start.add(Duration(days: index)));
    return SafeArea(
      bottom: false,
      child: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.playerAccent)),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(playerLoadMessage(error), style: AppTextStyles.bodyOnDark, textAlign: TextAlign.center),
          ),
        ),
        data: (List<PlayerSessionModel> rows) {
          final List<PlayerSessionModel> selected = rows.where((PlayerSessionModel row) => _sameDate(row.date, _selectedDay)).toList();
          final List<PlayerSessionModel> upcoming = rows.where((PlayerSessionModel row) {
            final DateTime? date = row.date;
            return date != null && date.isAfter(start);
          }).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
            children: <Widget>[
              const Text('Schedule', style: AppTextStyles.pageTitle),
              const SizedBox(height: 4),
              Text(_monthYear(start), style: AppTextStyles.caption),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (final DateTime day in days)
                    DayChip(
                      label: _weekday(day),
                      day: '${day.day}',
                      selected: _sameDate(day, _selectedDay),
                      onTap: () => setState(() => _selectedDay = day),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(_sameDate(_selectedDay, start) ? 'Today' : formatApiDate(_selectedDay.toIso8601String()), style: AppTextStyles.heading),
              const SizedBox(height: 10),
              if (selected.isEmpty)
                const Text('No session on this day.', style: AppTextStyles.caption)
              else
                ...selected.map((PlayerSessionModel session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ScheduleTile(session: session),
                    )),
              const SizedBox(height: 12),
              const Text('Upcoming sessions', style: AppTextStyles.heading),
              const SizedBox(height: 10),
              if (upcoming.isEmpty)
                const Text('No upcoming sessions.', style: AppTextStyles.caption)
              else
                ...upcoming.map((PlayerSessionModel session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ScheduleTile(session: session),
                    )),
            ],
          );
        },
      ),
    );
  }
}

bool _sameDate(DateTime? a, DateTime b) => a != null && a.year == b.year && a.month == b.month && a.day == b.day;

String _weekday(DateTime day) {
  const List<String> labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[day.weekday - 1];
}

String _monthYear(DateTime day) {
  const List<String> months = <String>['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${months[day.month - 1]} ${day.year}';
}

class _ScheduleTile extends ConsumerWidget {
  const _ScheduleTile({required this.session});

  final PlayerSessionModel session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool marked = session.attendanceStatus != null;
    return SessionTile(
      date: session.session.dateLabel,
      time: session.session.timeRange,
      batch: session.session.batchName,
      detail: session.skipped ? '${session.detail} · Noted: ${session.skipReason}' : session.detail,
      pitch: session.session.ground,
      borderColor: session.skipped ? AppColors.playerCoral : null,
      badge: sessionBadge(session, fallback: const StatusPill("You're in")),
      footer: marked
          ? null
          : TextButton(
              onPressed: () => skipOrUndoSession(
                context,
                ref,
                session,
                '${session.session.dateLabel}, ${session.session.timeRange}',
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.playerCoral,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(session.skipped ? 'Undo skip' : 'Skip session', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
    );
  }
}
