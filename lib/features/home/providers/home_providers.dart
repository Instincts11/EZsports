import 'package:ezsports/features/home/data/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepositoryProvider = Provider<HomeRepository>((Ref ref) {
  return HomeRepository();
});
