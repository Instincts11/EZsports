import 'package:ezsports/features/classes/data/classes_repository.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classesRepositoryProvider = Provider<ClassesRepository>((Ref ref) {
  return ClassesRepository();
});

final sessionsProvider = FutureProvider.autoDispose<List<SessionModel>>((Ref ref) {
  return ref.watch(classesRepositoryProvider).fetchSessions();
});

final sessionFilterProvider = StateProvider<String>((Ref ref) => 'upcoming');
