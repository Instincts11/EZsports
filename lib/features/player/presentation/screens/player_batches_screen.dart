import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerBatchesScreen extends StatelessWidget {
  const PlayerBatchesScreen({super.key});

  static const List<_FixtureItem> _fixtures = <_FixtureItem>[
    _FixtureItem(
      opponent: 'Kochi United',
      when: 'Sun 13 Sep · 5:30 PM',
      place: 'Pitch B · home',
      status: 'Called up · meet 4:45 PM',
      yours: true,
    ),
    _FixtureItem(
      opponent: 'Academy Cup',
      when: 'Sat 20 Sep · 7:30 AM',
      place: 'Home pitch · group stage',
      status: 'Squad not named yet',
    ),
    _FixtureItem(
      opponent: 'Harbour FC',
      when: 'Sun 30 Aug · full time',
      place: 'Away · 2–1 win',
      status: 'You played 20 minutes',
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
                child: Text('My fixtures', style: AppTextStyles.pageTitle),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text('U-14 · 1 call-up this month', style: AppTextStyles.muted),
          ),
          const SizedBox(height: 16),
          ..._fixtures.map(
            (_FixtureItem fixture) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FixtureCard(fixture: fixture),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Match day', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            borderColor: AppColors.playerGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'KOCHI UNITED',
                  style: TextStyle(
                    color: AppColors.playerAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Be at Pitch B by 4:45 PM',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.playerAccent),
                ),
                SizedBox(height: 4),
                Text('Home kit, white socks, shin pads, water.', style: TextStyle(color: AppColors.playerInk)),
                Text('Warm up with the starters. You are named on the bench.', style: TextStyle(color: Color(0xFF5C564E))),
                SizedBox(height: 14),
                Text('Kickoff', style: AppTextStyles.muted),
                Text(
                  'Sun 13 Sep · 5:30 PM',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk),
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
                Text('Not on the sheet?', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  'Academy Cup on 20 Sep is still open. Coach Nair names that squad on Thursday. Training still happens even if you are not selected.',
                  style: TextStyle(color: AppColors.playerMuted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Recent result', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          const CreamCard(
            color: AppColors.playerCream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Harbour FC · 2–1', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerAccent)),
                SizedBox(height: 4),
                Text('Sun 30 Aug, away. You came on after 70 minutes and held the right side. The winning goal was already scored.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FixtureItem {
  const _FixtureItem({
    required this.opponent,
    required this.when,
    required this.place,
    required this.status,
    this.yours = false,
  });

  final String opponent;
  final String when;
  final String place;
  final String status;
  final bool yours;
}

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture});

  final _FixtureItem fixture;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      color: AppColors.playerCream,
      borderColor: fixture.yours ? AppColors.playerGold : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(fixture.opponent, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                const SizedBox(height: 4),
                Text(fixture.when, style: const TextStyle(color: Color(0xFF5C564E))),
                const SizedBox(height: 8),
                Text(fixture.place, style: const TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  fixture.status,
                  style: TextStyle(
                    color: fixture.yours ? AppColors.playerAccent : const Color(0xFF5C564E),
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
