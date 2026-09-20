import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';

class AttendanceRepository {
  Future<void> markCoachAttendance({required int sessionId, required String status}) async {
    await DioClient.instance.post(
      ApiEndpoints.coachAttendance(sessionId),
      data: <String, String>{'status': status},
    );
  }

  Future<void> markStudentAttendance({
    required int sessionId,
    required int studentId,
    required String status,
  }) async {
    await DioClient.instance.post(
      ApiEndpoints.studentAttendance(sessionId),
      data: <String, Object>{'student_id': studentId, 'status': status},
    );
  }
}
