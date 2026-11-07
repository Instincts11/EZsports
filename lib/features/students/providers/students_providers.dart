import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentsRepositoryProvider = Provider<StudentsRepository>((Ref ref) {
  return StudentsRepository();
});

final batchesProvider = FutureProvider<List<BatchModel>>((Ref ref) {
  return ref.watch(studentsRepositoryProvider).fetchBatches();
});

final playersProvider = FutureProvider<List<StudentModel>>((Ref ref) {
  return ref.watch(studentsRepositoryProvider).fetchStudents();
});

final studentProvider = FutureProvider.family<StudentModel, int>((Ref ref, int id) {
  return ref.watch(studentsRepositoryProvider).fetchStudent(id);
});

final batchRosterProvider = FutureProvider.family<List<StudentModel>, int>((Ref ref, int batchId) {
  return ref.watch(studentsRepositoryProvider).fetchBatchStudents(batchId);
});

final sessionRosterProvider = FutureProvider.family<List<StudentModel>, int>((Ref ref, int sessionId) {
  return ref.watch(studentsRepositoryProvider).fetchSessionRoster(sessionId);
});

AsyncValue<List<BatchModel>> watchBatches(WidgetRef ref) {
  return ref.watch(batchesProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.batches, BatchModel.fromJson),
      );
}

AsyncValue<List<StudentModel>> watchPlayers(WidgetRef ref) {
  return ref.watch(playersProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.students, StudentModel.fromJson),
      );
}

AsyncValue<StudentModel> watchStudent(WidgetRef ref, int id) {
  return ref.watch(studentProvider(id)).orStored(
        ResponseCache.map('${ApiEndpoints.students}/$id', StudentModel.fromJson),
      );
}

AsyncValue<List<StudentModel>> watchBatchRoster(WidgetRef ref, int batchId) {
  return ref.watch(batchRosterProvider(batchId)).orStored(
        ResponseCache.mapList(ApiEndpoints.batchStudents(batchId), StudentModel.fromJson),
      );
}

AsyncValue<List<StudentModel>> watchSessionRoster(WidgetRef ref, int sessionId) {
  return ref.watch(sessionRosterProvider(sessionId)).orStored(
        ResponseCache.mapList(ApiEndpoints.sessionStudents(sessionId), StudentModel.fromJson),
      );
}
