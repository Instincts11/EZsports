import 'package:ezsports/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentsRepositoryProvider = Provider<StudentsRepository>((Ref ref) {
  return StudentsRepository();
});
