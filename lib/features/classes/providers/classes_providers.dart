import 'package:ezsports/features/classes/data/classes_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classesRepositoryProvider = Provider<ClassesRepository>((Ref ref) {
  return ClassesRepository();
});
