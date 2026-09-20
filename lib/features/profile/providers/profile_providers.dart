import 'package:ezsports/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  return ProfileRepository();
});
