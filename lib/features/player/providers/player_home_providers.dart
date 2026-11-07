import 'package:dio/dio.dart';
import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/providers/player_profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerHomeProvider = FutureProvider<PlayerHomeModel>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getHome();
});

final playerSessionsProvider = FutureProvider<List<PlayerSessionModel>>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getSessions();
});

final playerMatchesProvider = FutureProvider<List<MatchModel>>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getMatches();
});

final playerAttendanceProvider = FutureProvider<List<PlayerAttendanceModel>>((Ref ref) {
  return ref.watch(playerRepositoryProvider).getAttendance();
});

AsyncValue<PlayerHomeModel> watchPlayerHome(WidgetRef ref) {
  return ref.watch(playerHomeProvider).orStored(
        ResponseCache.map(ApiEndpoints.playerHome, PlayerHomeModel.fromJson),
      );
}

AsyncValue<List<PlayerSessionModel>> watchPlayerSessions(WidgetRef ref) {
  return ref.watch(playerSessionsProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.playerSessions, PlayerSessionModel.fromJson),
      );
}

AsyncValue<List<MatchModel>> watchPlayerMatches(WidgetRef ref) {
  return ref.watch(playerMatchesProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.playerMatches, MatchModel.fromJson),
      );
}

AsyncValue<List<PlayerAttendanceModel>> watchPlayerAttendance(WidgetRef ref) {
  return ref.watch(playerAttendanceProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.playerAttendance, PlayerAttendanceModel.fromJson),
      );
}

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
