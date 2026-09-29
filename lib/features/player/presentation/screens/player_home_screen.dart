import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:ezsports/features/player/providers/player_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerHomeScreen extends ConsumerWidget {
  const PlayerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionMark today = ref.watch(todaySessionProvider);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
        children: <Widget>[
          const Text('ID SPORTS', style: AppTextStyles.overline),
          const Text('Advaita S', style: AppTextStyles.displayName),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget date = const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('11:57 AM', style: AppTextStyles.bodyOnDark),
                    Text('06 Sep 2026 Sunday', style: AppTextStyles.caption),
                  ],
                ),
              );
              final Widget sessions = const Column(
                children: <Widget>[
                  Text('2', style: TextStyle(fontSize: 28, height: 1, fontWeight: FontWeight.w800, color: AppColors.textOnDark)),
                  Text('Sessions', style: AppTextStyles.caption),
                ],
              );
              final Widget checkIn = CheckInButton(checked: today.here, onPressed: () => _toggleHere(ref));
              if (constraints.maxWidth < 340) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.playerMuted),
                        const SizedBox(width: 8),
                        date,
                        sessions,
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: checkIn),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.playerMuted),
                  const SizedBox(width: 8),
                  date,
                  sessions,
                  const SizedBox(width: 10),
                  checkIn,
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const Row(
            children: <Widget>[
              Expanded(child: Text('My attendance', style: AppTextStyles.heading)),
              Text('01 Sep – 30 Sep', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Row(
              children: const <Widget>[
                Expanded(child: AttendanceRing(value: 8, label: 'Days', color: AppColors.playerAccent, progress: 0.78)),
                Expanded(child: AttendanceRing(value: 6, label: 'Attended', color: AppColors.playerAmber, progress: 0.62)),
                Expanded(child: AttendanceRing(value: 2, label: 'Missed', color: AppColors.playerCoral, progress: 0.28)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Today', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          SessionTile(
            date: '06 Sep Sunday',
            time: '3:30 PM to 5:00 PM',
            batch: 'Weekend Evening',
            detail: 'Coach: R. Nair',
            borderColor: today.skipped ? AppColors.playerCoral : AppColors.playerAccent,
            badge: today.skipped ? const StatusPill('Skipped', tone: PillTone.coral) : null,
            footer: _TodayActions(mark: today),
          ),
          const SizedBox(height: 22),
          PlayerSectionTitle(
            'This week',
            action: 'See schedule ›',
            onAction: () => context.go('/player/schedule'),
          ),
          const SizedBox(height: 10),
          const SessionTile(
            date: 'Mon 07 Sep',
            time: '4:00 PM to 6:00 PM',
            batch: 'Weekday Evening',
            detail: 'Coach: R. Nair',
          ),
          const SizedBox(height: 10),
          const SessionTile(
            date: 'Thu 10 Sep',
            time: '4:30 PM to 6:00 PM',
            batch: 'Weekday Evening',
            detail: 'Coach: R. Nair',
          ),
          const SizedBox(height: 10),
          const SessionTile(
            date: 'Sat 12 Sep',
            time: '7:00 AM to 9:00 AM',
            batch: 'Weekend Morning',
            detail: 'Coach: R. Nair',
          ),
          const SizedBox(height: 10),
          const SessionTile(
            date: 'Sun 13 Sep',
            time: '3:30 PM to 5:00 PM',
            batch: 'Weekend Evening',
            detail: 'Coach: R. Nair',
            badge: StatusPill('Next', tone: PillTone.solid),
          ),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: _GoldDot(),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Coach note', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.playerInk)),
                      SizedBox(height: 2),
                      Text('Bring shin guards. Pitch B.', style: TextStyle(color: AppColors.playerInk)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Recent check-ins', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: <Widget>[
                _CheckInRow('06 Sep · Weekend Evening', missed: false),
                _CheckInRow('31 Aug · Weekend Evening', missed: false),
                _CheckInRow('30 Aug · Weekend Evening', missed: true),
                _CheckInRow('24 Aug · Weekend Evening', missed: false),
                _CheckInRow('23 Aug · Weekend Evening', missed: false),
                _CheckInRow('17 Aug · Weekend Evening', missed: false),
                _CheckInRow('16 Aug · Weekend Evening', missed: false),
                _CheckInRow('10 Aug · Weekend Evening', missed: true),
                _CheckInRow('09 Aug · Weekend Evening', missed: false),
                _CheckInRow('02 Aug · Weekend Evening', missed: false, last: true),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('From the academy', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'NOTICE',
            title: 'Sunday session moves to Pitch B',
            body: 'Weekend evening stays 3:30 PM to 5:00 PM. Gate opens 20 minutes early.',
          ),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'KIT',
            title: 'Jersey 7 · navy training top',
            body: 'Bring water and both pairs of boots. No jewellery on the pitch.',
          ),
          const SizedBox(height: 22),
          const Text("Today's work", style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'WARM-UP · 10 MIN',
            title: 'Rondo, then dynamic stretches',
            body: 'Join the 4v1 as soon as you pass the gate. Shin guards on before the first pass.',
          ),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'BLOCK 1',
            title: 'First touch on the half-turn',
            body: 'Receive side-on between the cones. Open your body toward Pitch B’s far goal before the ball arrives.',
          ),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'BLOCK 2',
            title: '3v2 to goal',
            body: 'You start as the extra attacker. If you lose the ball, you are the first defender back.',
          ),
          const SizedBox(height: 22),
          const Text('Pack for today', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _PackLine('Navy training top and jersey 7'),
                _PackLine('Moulded boots. Studs only if the grass is wet'),
                _PackLine('Shin guards. Leave them on until you reach the gate'),
                _PackLine('750 ml water. No fizzy drinks on the sideline'),
                _PackLine('A dry shirt for the ride home', last: true),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Fees', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('September · ₹2,500 due 10 Sep', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 6),
                Text('June, July and August are paid. Meera S can clear September at the front desk before Sunday 13 Sep. Training continues either way this week.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Getting here', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'GATE',
            title: 'Pitch B gate opens at 3:10 PM',
            body: 'Pickup is 5:10 PM from the same gate, not the main road. Tell Meera if you will be more than 10 minutes late.',
          ),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'WEATHER',
            title: 'Light showers after 4 PM',
            body: 'The session stays outdoors unless the groundsman closes Pitch B. A dry shirt is enough. No hoods on the pitch.',
          ),
          const SizedBox(height: 22),
          const Text('On your rest days', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'TUE · WED · FRI',
            title: '20 minutes at home',
            body: '20 wall passes with the left foot, then 8 cone touches each foot, slow and then at match speed. No filming needed. Coach Nair checks it on Sunday.',
          ),
          const SizedBox(height: 10),
          const _NoticeCard(
            kicker: 'PARENTS',
            title: 'Meet Coach Nair on Sat 12 Sep',
            body: '9:15 AM, after Weekend Morning, outside the Pitch B shed. Topic: the 27 Sep friendly against Kochi Youth.',
          ),
        ],
      ),
    );
  }
}

void _toggleHere(WidgetRef ref) {
  final SessionMark current = ref.read(todaySessionProvider);
  ref.read(todaySessionProvider.notifier).state = SessionMark(here: !current.here);
}

class _TodayActions extends ConsumerWidget {
  const _TodayActions({required this.mark});

  final SessionMark mark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (mark.skipped)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Coach Nair has this: ${mark.skipReason}',
              style: const TextStyle(color: AppColors.playerCoral, fontWeight: FontWeight.w700),
            ),
          ),
        TextButton(
          onPressed: () => _skipOrUndo(context, ref),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.playerCoral,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(mark.skipped ? 'Undo skip' : 'Skip session', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: CheckInButton(checked: mark.here, onPressed: () => _toggleHere(ref)),
        ),
      ],
    );
  }

  Future<void> _skipOrUndo(BuildContext context, WidgetRef ref) async {
    if (mark.skipped) {
      ref.read(todaySessionProvider.notifier).state = const SessionMark();
      return;
    }
    final String? reason = await showSkipSessionSheet(context, sessionLabel: 'today, 3:30 PM');
    if (reason == null) {
      return;
    }
    ref.read(todaySessionProvider.notifier).state = SessionMark(skipReason: reason);
  }
}

class _GoldDot extends StatelessWidget {
  const _GoldDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(color: AppColors.playerGold, shape: BoxShape.circle),
    );
  }
}

class _CheckInRow extends StatelessWidget {
  const _CheckInRow(this.label, {required this.missed, this.last = false});

  final String label;
  final bool missed;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w600))),
              StatusPill(missed ? 'Missed' : 'On time', tone: missed ? PillTone.coral : PillTone.teal),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, color: AppColors.playerLine),
      ],
    );
  }
}

class _PackLine extends StatelessWidget {
  const _PackLine(this.text, {this.last = false});

  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 6), child: _GoldDot()),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, color: AppColors.playerLine),
      ],
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
