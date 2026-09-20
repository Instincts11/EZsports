import 'package:ezsports/features/matches/data/matches_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>((Ref ref) {
  return MatchesRepository();
});
