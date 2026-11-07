import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/matches/data/matches_repository.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>((Ref ref) {
  return MatchesRepository();
});

final matchesProvider = FutureProvider<List<MatchModel>>((Ref ref) {
  return ref.watch(matchesRepositoryProvider).fetchMatches();
});

AsyncValue<List<MatchModel>> watchMatches(WidgetRef ref) {
  return ref.watch(matchesProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.matches, MatchModel.fromJson),
      );
}
