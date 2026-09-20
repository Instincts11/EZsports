import 'package:ezsports/features/admin/data/admin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminRepositoryProvider = Provider<AdminRepository>((Ref ref) {
  return AdminRepository();
});
