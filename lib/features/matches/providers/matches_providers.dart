import 'package:ezsports/features/matches/data/matches_repository.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>((Ref ref) {
  return MatchesRepository();
});

final matchesProvider = FutureProvider.autoDispose<List<MatchModel>>((Ref ref) {
  return ref.watch(matchesRepositoryProvider).fetchMatches();
});
