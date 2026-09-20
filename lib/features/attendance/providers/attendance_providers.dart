import 'package:ezsports/features/attendance/data/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((Ref ref) {
  return AttendanceRepository();
});
