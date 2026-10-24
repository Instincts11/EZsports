import 'package:dio/dio.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/providers/player_profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerHomeProvider = FutureProvider.autoDispose<PlayerHomeModel>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getHome();
});

final playerSessionsProvider = FutureProvider.autoDispose<List<PlayerSessionModel>>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getSessions();
});

final playerMatchesProvider = FutureProvider.autoDispose<List<MatchModel>>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getMatches();
});

final playerAttendanceProvider = FutureProvider.autoDispose<List<PlayerAttendanceModel>>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getAttendance();
});

Future<void> respondToSession(
  WidgetRef ref,
  int sessionId, {
  bool? checkedIn,
  String? skipReason,
  bool clearSkip = false,
}) async {
  await ref.read(playerRepositoryProvider).respondToSession(
        sessionId,
        checkedIn: checkedIn,
        skipReason: skipReason,
        clearSkip: clearSkip,
      );
  ref.invalidate(playerHomeProvider);
  ref.invalidate(playerSessionsProvider);
}

String playerLoadMessage(Object error) {
  if (error is DioException && error.response?.statusCode == 401) {
    return 'Sign in as a player to load your academy data.';
  }
  return 'Could not load academy data.';
}
