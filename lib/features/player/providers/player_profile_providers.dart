import 'package:ezsports/features/player/data/models/player_profile_model.dart';
import 'package:ezsports/features/player/data/player_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((Ref ref) {
  return PlayerRepository();
});

final playerProfileProvider = FutureProvider.autoDispose<PlayerProfileModel>((Ref ref) async {
  return ref.watch(playerRepositoryProvider).getProfile();
});
