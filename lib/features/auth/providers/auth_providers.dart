import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezsports/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepository();
});
