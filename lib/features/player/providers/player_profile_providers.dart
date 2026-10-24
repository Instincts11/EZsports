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
  return starterPlayerProfile;
});

final playerProfileProvider = FutureProvider.autoDispose<PlayerProfileModel>((Ref ref) async {
  return ref.watch(playerRepositoryProvider).getProfile();
});

Future<void> refreshPlayerDraft(WidgetRef ref) async {
  try {
    final PlayerProfileModel profile = await ref.read(playerRepositoryProvider).getProfile();
    ref.read(playerDraftProvider.notifier).state = profile;
  } catch (_) {
    // Keep the editable profile already on screen when the player is not signed in.
  }
}
