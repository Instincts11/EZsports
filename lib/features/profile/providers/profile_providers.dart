import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/profile/data/models/coach_profile_model.dart';
import 'package:ezsports/features/profile/data/models/leave_model.dart';
import 'package:ezsports/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  return ProfileRepository();
});

final coachProfileProvider = FutureProvider<CoachProfileModel>((Ref ref) {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});

final coachLeavesProvider = FutureProvider<List<LeaveModel>>((Ref ref) {
  return ref.watch(profileRepositoryProvider).fetchLeaves();
});

AsyncValue<CoachProfileModel> watchCoachProfile(WidgetRef ref) {
  return ref.watch(coachProfileProvider).orStored(
        ResponseCache.map(ApiEndpoints.profile, CoachProfileModel.fromJson),
      );
}

AsyncValue<List<LeaveModel>> watchCoachLeaves(WidgetRef ref) {
  return ref.watch(coachLeavesProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.leaves, LeaveModel.fromJson),
      );
}
