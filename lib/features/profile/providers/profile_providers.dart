import 'package:ezsports/features/profile/data/models/coach_profile_model.dart';
import 'package:ezsports/features/profile/data/models/leave_model.dart';
import 'package:ezsports/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  return ProfileRepository();
});

final coachProfileProvider = FutureProvider.autoDispose<CoachProfileModel>((Ref ref) {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});

final coachLeavesProvider = FutureProvider.autoDispose<List<LeaveModel>>((Ref ref) {
  return ref.watch(profileRepositoryProvider).fetchLeaves();
});
