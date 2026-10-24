import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/matches/providers/matches_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MatchModel>> matches = ref.watch(matchesProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
        children: <Widget>[
          const Text(AppStrings.batches, style: AppTextStyles.pageTitle),
          const SizedBox(height: 6),
          matches.maybeWhen(
            data: (List<MatchModel> items) {
              final int open = items.where((MatchModel match) => match.status != 'previous').length;
              return Text(
                '${items.length} matches · $open still open',
                style: AppTextStyles.muted,
              );
            },
            orElse: () => const Text('Fixtures from the academy', style: AppTextStyles.muted),
          ),
          const SizedBox(height: 20),
          matches.when(
            data: (List<MatchModel> items) {
              if (items.isEmpty) {
                return const Text('No fixtures have been added yet.', style: AppTextStyles.muted);
              }
              return Column(
                children: items
                    .map(
                      (MatchModel match) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FixtureCard(
                          opponent: match.opponentLabel,
                          kickoff: match.kickoff,
                          detail: match.detail,
                          lineup: match.lineupLabel,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (Object error, StackTrace stack) => const Text(
              'Sign in as a coach to load fixtures.',
              style: AppTextStyles.muted,
            ),
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
          if (detail.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(detail, style: AppTextStyles.muted),
          ],
          const SizedBox(height: 4),
          Text(lineup, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
