import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/app_store.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/classes/data/classes_repository.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classesRepositoryProvider = Provider<ClassesRepository>((Ref ref) {
  return ClassesRepository();
});

final sessionsProvider = FutureProvider<List<SessionModel>>((Ref ref) {
  return ref.watch(classesRepositoryProvider).fetchSessions();
});

AsyncValue<List<SessionModel>> watchSessions(WidgetRef ref) {
  return ref.watch(sessionsProvider).orStored(
        ResponseCache.mapList(ApiEndpoints.sessions, SessionModel.fromJson),
      );
}

final sessionFilterProvider = StateProvider<String>((Ref ref) => AppStore.sessionFilter);

final sessionRangeProvider = StateProvider<DateTimeRange?>((Ref ref) {
  final DateTime? start = AppStore.rangeStart;
  final DateTime? end = AppStore.rangeEnd;
  if (start == null || end == null) {
    return null;
  }
  return DateTimeRange(start: start, end: end);
});
