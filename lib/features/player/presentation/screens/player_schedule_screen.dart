import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:ezsports/features/player/providers/player_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerScheduleScreen extends ConsumerStatefulWidget {
  const PlayerScheduleScreen({super.key});

  @override
  ConsumerState<PlayerScheduleScreen> createState() => _PlayerScheduleScreenState();
}

class _PlayerScheduleScreenState extends ConsumerState<PlayerScheduleScreen> {
  int _selectedDay = 6;

  static const List<(String, String)> _days = <(String, String)>[
    ('Sun', '6'),
    ('Mon', '7'),
    ('Tue', '8'),
    ('Wed', '9'),
    ('Thu', '10'),
    ('Fri', '11'),
  ];

  static const List<_LaterSession> _later = <_LaterSession>[
    _LaterSession('Mon 06 Sep', '3:30 PM – 5:00 PM', 'Weekend Evening', 'Pitch B · Coach R. Nair', true),
    _LaterSession('Mon 06 Sep', '7:00 AM – 9:00 AM', 'Summer Camp', 'Pitch A · Coach R. Nair', false),
    _LaterSession('Mon 07 Sep', '4:00 PM – 6:00 PM', 'Summer Camp', 'Pitch A · Coach R. Nair', false),
    _LaterSession('Mon 07 Sep', '4:30 PM – 6:00 PM', 'Weekday Evening Batch', 'Pitch A · Coach R. Nair', false),
    _LaterSession('Thu 10 Sep', '4:30 PM – 6:00 PM', 'Weekday Evening Batch', 'Pitch A · Coach R. Nair', false),
    _LaterSession('Sat 12 Sep', '7:00 AM – 9:00 AM', 'Weekend Morning', 'Pitch B · Coach R. Nair', false),
    _LaterSession('Sun 13 Sep', '3:30 PM – 5:00 PM', 'Weekend Evening', 'Pitch B · Coach R. Nair', true),
    _LaterSession('Mon 14 Sep', '4:00 PM – 6:00 PM', 'Summer Camp', 'Pitch A · Coach R. Nair', false),
    _LaterSession('Sat 19 Sep', '7:00 AM – 9:00 AM', 'Weekend Morning', 'Pitch B · Coach R. Nair', false),
    _LaterSession('Sun 20 Sep', '3:30 PM – 5:00 PM', 'Weekend Evening', 'Pitch B · Coach R. Nair', true),
    _LaterSession('Sat 26 Sep', '3:30 PM – 5:00 PM', 'Weekend Evening', 'Pitch B · Coach R. Nair', true),
    _LaterSession('Sun 27 Sep', '3:30 PM – 5:00 PM', 'Weekend Evening', 'Pitch B · set pieces', true),
    _LaterSession('Sun 27 Sep', '5:30 PM – 6:40 PM', 'U-14 friendly · Kochi Youth', 'Pitch B · bib over jersey 7', true),
  ];

  @override
  Widget build(BuildContext context) {
    final SessionMark today = ref.watch(todaySessionProvider);
    final Map<String, String> skipped = ref.watch(skippedSessionsProvider);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
        children: <Widget>[
          const Text('Schedule', style: AppTextStyles.pageTitle),
          const SizedBox(height: 4),
          const Text('September 2026 · Esperanza Football Academy', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<Widget> chips = <Widget>[
                for (final (String label, String day) in _days)
                  DayChip(
                    label: label,
                    day: day,
                    selected: int.parse(day) == _selectedDay,
                    onTap: () => setState(() => _selectedDay = int.parse(day)),
                  ),
              ];
              final Widget spread = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: chips,
              );
              if (constraints.maxWidth >= 300) {
                return spread;
              }
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 300, child: spread),
              );
            },
          ),
          const SizedBox(height: 20),
          const Row(
            children: <Widget>[
              Expanded(child: Text('Today', style: AppTextStyles.heading)),
              Text('06 Sep Sunday', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 10),
          SessionTile(
            date: 'YOUR SESSION',
            time: '3:30 PM to 5:00 PM',
            batch: 'Weekend Evening · Pitch B',
            detail: 'Coach R. Nair · 15 players',
            borderColor: today.skipped ? AppColors.playerCoral : AppColors.playerAccent,
            badge: today.skipped ? const StatusPill('Skipped', tone: PillTone.coral) : null,
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (today.skipped)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Coach Nair has this: ${today.skipReason}',
                      style: const TextStyle(color: AppColors.playerCoral, fontWeight: FontWeight.w700),
                    ),
                  ),
                TextButton(
                  onPressed: () => _skipToday(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.playerCoral,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(today.skipped ? 'Undo skip' : 'Skip session', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: CheckInButton(
                    checked: today.here,
                    onPressed: () {
                      final SessionMark current = ref.read(todaySessionProvider);
                      ref.read(todaySessionProvider.notifier).state = SessionMark(here: !current.here);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Later this month', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          ..._later.map(
            (_LaterSession session) {
              final String key = '${session.date}|${session.time}';
              final String? reason = skipped[key];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SessionTile(
                  date: session.date,
                  time: session.time,
                  batch: session.batch,
                  detail: session.place,
                  borderColor: reason == null ? null : AppColors.playerCoral,
                  badge: reason != null
                      ? const StatusPill('Skipped', tone: PillTone.coral)
                      : (session.yours ? const StatusPill("You're in") : null),
                  footer: session.yours
                      ? _LaterSkip(
                          reason: reason,
                          onPressed: () => _skipLater(context, key, session),
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'No sessions on Tue, Wed or Fri for your batch',
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 18),
          const Text('How to use the off days', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Tuesday and Wednesday', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 4),
                Text('Left-foot wall passes and a slow jog. Stop if the shin feels hot. Tell Coach Nair before Sunday if you skip it.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
                SizedBox(height: 12),
                Text('Friday', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 4),
                Text('Short touches only. Save the legs for Saturday if you also join Weekend Morning as a guest.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('27 Sep friendly', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 4),
                Text('Train at 3:30, then stay for the U-14 game at 5:30 if Meera confirms pickup by Friday. Bib goes over jersey 7. Water only at half-time.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _skipToday(BuildContext context) async {
    final SessionMark current = ref.read(todaySessionProvider);
    if (current.skipped) {
      ref.read(todaySessionProvider.notifier).state = const SessionMark();
      return;
    }
    final String? reason = await showSkipSessionSheet(context, sessionLabel: 'today, 3:30 PM');
    if (reason == null) {
      return;
    }
    ref.read(todaySessionProvider.notifier).state = SessionMark(skipReason: reason);
  }

  Future<void> _skipLater(BuildContext context, String key, _LaterSession session) async {
    final Map<String, String> current = ref.read(skippedSessionsProvider);
    if (current.containsKey(key)) {
      final Map<String, String> next = Map<String, String>.from(current)..remove(key);
      ref.read(skippedSessionsProvider.notifier).state = next;
      return;
    }
    final String? reason = await showSkipSessionSheet(context, sessionLabel: '${session.date}, ${session.time}');
    if (reason == null) {
      return;
    }
    ref.read(skippedSessionsProvider.notifier).state = <String, String>{...current, key: reason};
  }
}

class _LaterSkip extends StatelessWidget {
  const _LaterSkip({required this.reason, required this.onPressed});

  final String? reason;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (reason != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('Coach Nair has this: $reason', style: const TextStyle(color: AppColors.playerCoral, fontWeight: FontWeight.w700)),
          ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.playerCoral,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(reason == null ? 'Skip session' : 'Undo skip', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _LaterSession {
  const _LaterSession(this.date, this.time, this.batch, this.place, this.yours);

  final String date;
  final String time;
  final String batch;
  final String place;
  final bool yours;
}
