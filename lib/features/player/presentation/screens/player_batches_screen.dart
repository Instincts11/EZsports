import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerBatchesScreen extends StatelessWidget {
  const PlayerBatchesScreen({super.key});

  static const List<_BatchItem> _batches = <_BatchItem>[
    _BatchItem(
      name: 'Summer Camp',
      schedule: 'Tue Wed Thu Sat Mon · 7:00 AM – 9:00 AM',
      meta: '17 players · Coach R. Nair',
      next: 'Next · Mon 07 Sep',
    ),
    _BatchItem(
      name: 'Weekday Evening Batch',
      schedule: 'Mon Wed Fri · 4:00 PM – 6:00 PM',
      meta: '4 players · Coach R. Nair',
      next: 'Next · Mon 07 Sep',
    ),
    _BatchItem(
      name: 'Weekend Evening',
      schedule: 'Sun Sat · 3:30 PM – 5:00 PM',
      meta: '15 players · Coach R. Nair',
      next: 'Your batch · today',
      yours: true,
    ),
    _BatchItem(
      name: 'Weekend Morning',
      schedule: 'Sun Sat · 7:00 AM – 9:00 AM',
      meta: '107 players · Coach R. Nair',
      next: 'Next · Sat 12 Sep',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 4, AppSizes.screenPadding, 28),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => context.go('/player/home'),
                icon: const Icon(AppIcons.back, color: AppColors.textOnDark),
              ),
              const Expanded(
                child: Text('My batches', style: AppTextStyles.pageTitle),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text('Total players in academy : 143', style: AppTextStyles.muted),
          ),
          const SizedBox(height: 16),
          ..._batches.map(
            (_BatchItem batch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BatchCard(batch: batch),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Also at the academy', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              children: <Widget>[
                _ClinicRow(name: 'Goalkeeper Clinic', when: 'Sat · 5:30 PM', players: '9 players'),
                Divider(height: 22, color: AppColors.playerLine),
                _ClinicRow(name: 'U-14 Match Prep', when: 'Thu · 4:30 PM', players: '12 players'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Your batch', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          CreamCard(
            color: AppColors.playerCream,
            borderColor: AppColors.playerGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'ENROLLED',
                  style: TextStyle(
                    color: AppColors.playerAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Weekend Evening',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.playerAccent),
                ),
                const SizedBox(height: 4),
                const Text('Sun Sat · 3:30 PM – 5:00 PM', style: TextStyle(color: AppColors.playerInk)),
                const Text('Pitch B · Coach R. Nair · 15 players', style: TextStyle(color: Color(0xFF5C564E))),
                const SizedBox(height: 14),
                const Text('Next session', style: AppTextStyles.muted),
                const Text(
                  'Sun 13 Sep · 3:30 PM',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => context.go('/player/schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.playerAccent,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('View schedule', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.playerCardAlt,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Need a different group?', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  'Ask the front desk to move batches. Changes apply from the next Sunday.',
                  style: TextStyle(color: AppColors.playerMuted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('What each group is for', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Weekend Evening · yours', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerAccent)),
                SizedBox(height: 4),
                Text('Match habits for players who already train twice a week. Small numbers, so you get repeats.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
                SizedBox(height: 12),
                Text('Weekend Morning', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 4),
                Text('The big group. Good for extra touches, not for the 3v2 work you do at 3:30.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
                SizedBox(height: 12),
                Text('Summer Camp', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 4),
                Text('Holiday block through September. Open to your age group if a guardian registers by Friday.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
                SizedBox(height: 12),
                Text('Weekday Evening', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 4),
                Text('Four players only. Built for players who need a quieter pitch. Not a drop-in.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('September dates that matter', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                SizedBox(height: 8),
                Text('10 Sep · September fee due', style: TextStyle(color: AppColors.playerInk)),
                Text('12 Sep · parent chat after morning training', style: TextStyle(color: AppColors.playerInk)),
                Text('13 Sep · your next Weekend Evening', style: TextStyle(color: AppColors.playerInk)),
                Text('27 Sep · U-14 friendly, stay after training', style: TextStyle(color: AppColors.playerInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchItem {
  const _BatchItem({
    required this.name,
    required this.schedule,
    required this.meta,
    required this.next,
    this.yours = false,
  });

  final String name;
  final String schedule;
  final String meta;
  final String next;
  final bool yours;
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({required this.batch});

  final _BatchItem batch;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      color: AppColors.playerCream,
      borderColor: batch.yours ? AppColors.playerGold : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(batch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                const SizedBox(height: 4),
                Text(batch.schedule, style: const TextStyle(color: Color(0xFF5C564E))),
                const SizedBox(height: 8),
                Text(batch.meta, style: const TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  batch.next,
                  style: TextStyle(
                    color: batch.yours ? AppColors.playerAccent : const Color(0xFF5C564E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(AppIcons.chevron, color: Color(0xFFB7A99A)),
        ],
      ),
    );
  }
}

class _ClinicRow extends StatelessWidget {
  const _ClinicRow({required this.name, required this.when, required this.players});

  final String name;
  final String when;
  final String players;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
              Text(when, style: const TextStyle(color: Color(0xFF5C564E))),
            ],
          ),
        ),
        Text(players, style: const TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
