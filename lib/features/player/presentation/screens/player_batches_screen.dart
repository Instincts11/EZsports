import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/player/providers/player_home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerBatchesScreen extends ConsumerWidget {
  const PlayerBatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MatchModel>> matches = ref.watch(playerMatchesProvider);
    return SafeArea(
      bottom: false,
      child: matches.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.playerAccent)),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(playerLoadMessage(error), style: AppTextStyles.bodyOnDark, textAlign: TextAlign.center),
          ),
        ),
        data: (List<MatchModel> rows) {
          final List<MatchModel> upcoming = rows.where((MatchModel match) => match.status != 'previous').toList();
          final List<MatchModel> previous = rows.where((MatchModel match) => match.status == 'previous').toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 4, AppSizes.screenPadding, 28),
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.go('/player/home'),
                    icon: const Icon(AppIcons.back, color: AppColors.textOnDark),
                  ),
                  const Expanded(child: Text('My fixtures', style: AppTextStyles.pageTitle)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  upcoming.isEmpty ? 'No upcoming fixtures' : '${upcoming.length} upcoming',
                  style: AppTextStyles.muted,
                ),
              ),
              const SizedBox(height: 16),
              if (rows.isEmpty)
                const Text('No fixtures for your batches yet.', style: AppTextStyles.caption)
              else
                ...rows.map(
                  (MatchModel fixture) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FixtureCard(fixture: fixture, highlighted: upcoming.isNotEmpty && fixture.matchId == upcoming.first.matchId),
                  ),
                ),
              if (upcoming.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                const Text('Match day', style: AppTextStyles.heading),
                const SizedBox(height: 10),
                CreamCard(
                  color: AppColors.playerCream,
                  borderColor: AppColors.playerGold,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        upcoming.first.opponentLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.playerAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        upcoming.first.batchName.isEmpty ? upcoming.first.opponentLabel : upcoming.first.batchName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.playerAccent),
                      ),
                      const SizedBox(height: 14),
                      const Text('Kickoff', style: AppTextStyles.muted),
                      if (upcoming.first.venue.isNotEmpty)
                        Text(upcoming.first.venue, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.playerInk)),
                      Text(
                        upcoming.first.kickoff,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk),
                      ),
                    ],
                  ),
                ),
              ],
              if (previous.isNotEmpty) ...<Widget>[
                const SizedBox(height: 22),
                const Text('Recent result', style: AppTextStyles.heading),
                const SizedBox(height: 10),
                CreamCard(
                  color: AppColors.playerCream,
                  child: Text(
                    <String>[
                      previous.last.opponentLabel,
                      if (previous.last.result.isNotEmpty) previous.last.result,
                      previous.last.kickoff,
                      if (previous.last.venue.isNotEmpty) previous.last.venue,
                    ].join(' · '),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerAccent),
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

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture, required this.highlighted});

  final MatchModel fixture;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      color: AppColors.playerCream,
      borderColor: highlighted ? AppColors.playerGold : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(fixture.opponentLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                const SizedBox(height: 4),
                Text(fixture.kickoff, style: const TextStyle(color: Color(0xFF5C564E))),
                if (fixture.venue.isNotEmpty) Text(fixture.venue, style: const TextStyle(color: Color(0xFF5C564E))),
                if (fixture.result.isNotEmpty)
                  Text(fixture.result, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                const SizedBox(height: 8),
                Text(fixture.batchName, style: const TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(fixture.lineupLabel, style: const TextStyle(color: Color(0xFF5C564E), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(AppIcons.chevron, color: Color(0xFFB7A99A)),
        ],
      ),
    );
  }
}
