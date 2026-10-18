import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:flutter/material.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
        children: const <Widget>[
          Text(AppStrings.batches, style: AppTextStyles.pageTitle),
          SizedBox(height: 6),
          Text('3 matches · 1 lineup still open', style: AppTextStyles.muted),
          SizedBox(height: 20),
          _FixtureCard(
            opponent: 'Kochi United',
            kickoff: 'Sun 13 Sep · 5:30 PM',
            detail: 'Pitch B · home · U-14 friendly',
            lineup: '16 named · bench set',
          ),
          SizedBox(height: 12),
          _FixtureCard(
            opponent: 'Academy Cup',
            kickoff: 'Sat 20 Sep · 7:30 AM',
            detail: 'Home pitch · group stage',
            lineup: 'Lineup open · name it by Thursday',
          ),
          SizedBox(height: 12),
          _FixtureCard(
            opponent: 'Harbour FC',
            kickoff: 'Sun 30 Aug · full time',
            detail: 'Away · result 2–1',
            lineup: 'Sheet not signed',
          ),
          SizedBox(height: 22),
          Text('Before kickoff', style: AppTextStyles.heading),
          SizedBox(height: 12),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Kochi United kit', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Home shirts are in the store. Count 16 bibs for the warm-up and leave two with the bench.', style: AppTextStyles.body),
              ],
            ),
          ),
          SizedBox(height: 12),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Academy Cup squad', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Pick 14 outfield players and 1 goalkeeper by Thursday evening. Weekend Evening players are first call.', style: AppTextStyles.body),
              ],
            ),
          ),
          SizedBox(height: 12),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Harbour FC sheet', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('The 2–1 result is on the board, but the match sheet is still unsigned. Sign it before Sunday’s team talk.', style: AppTextStyles.body),
              ],
            ),
          ),
          SizedBox(height: 18),
          Center(
            child: Text('Fixtures · Esperanza Football Academy', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({
    required this.opponent,
    required this.kickoff,
    required this.detail,
    required this.lineup,
  });

  final String opponent;
  final String kickoff;
  final String detail;
  final String lineup;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(opponent, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(kickoff, style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text(detail, style: AppTextStyles.muted),
          const SizedBox(height: 4),
          Text(lineup, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
