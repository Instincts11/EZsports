import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentsRepositoryProvider = Provider<StudentsRepository>((Ref ref) {
  return StudentsRepository();
});

final batchesProvider = FutureProvider.autoDispose<List<BatchModel>>((Ref ref) {
  return ref.watch(studentsRepositoryProvider).fetchBatches();
});

final playersProvider = FutureProvider.autoDispose<List<StudentModel>>((Ref ref) {
  return ref.watch(studentsRepositoryProvider).fetchStudents();
});

final studentProvider = FutureProvider.autoDispose.family<StudentModel, int>((Ref ref, int id) {
  return ref.watch(studentsRepositoryProvider).fetchStudent(id);
});

final batchRosterProvider = FutureProvider.autoDispose.family<List<StudentModel>, int>((Ref ref, int batchId) {
  return ref.watch(studentsRepositoryProvider).fetchBatchStudents(batchId);
});

final sessionRosterProvider = FutureProvider.autoDispose.family<List<StudentModel>, int>((Ref ref, int sessionId) {
  return ref.watch(studentsRepositoryProvider).fetchSessionRoster(sessionId);
});
