import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/player/data/models/player_profile_model.dart';
import 'package:ezsports/features/player/data/player_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((Ref ref) {
  return PlayerRepository();
});

const PlayerProfileModel starterPlayerProfile = PlayerProfileModel(
  studentId: 0,
  name: '',
  parentMobile: '',
);

final playerDraftProvider = StateProvider<PlayerProfileModel>((Ref ref) {
  return ResponseCache.map(ApiEndpoints.playerProfile, PlayerProfileModel.fromJson) ?? starterPlayerProfile;
});

final playerProfileProvider = FutureProvider<PlayerProfileModel>((Ref ref) async {
  return ref.watch(playerRepositoryProvider).getProfile();
});

AsyncValue<PlayerProfileModel> watchPlayerProfile(WidgetRef ref) {
  return ref.watch(playerProfileProvider).orStored(
        ResponseCache.map(ApiEndpoints.playerProfile, PlayerProfileModel.fromJson),
      );
}

Future<void> refreshPlayerDraft(WidgetRef ref) async {
  try {
    final PlayerProfileModel profile = await ref.read(playerRepositoryProvider).getProfile();
    ref.read(playerDraftProvider.notifier).state = profile;
  } catch (_) {
    // Keep the editable profile already on screen when the player is not signed in.
  }
}
