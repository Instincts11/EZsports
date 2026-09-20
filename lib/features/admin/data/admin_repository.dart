import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';

class AdminRepository {
  Future<void> createCoach(Map<String, dynamic> payload) async {
    await DioClient.instance.post(ApiEndpoints.coaches, data: payload);
  }

  Future<void> createStudent(Map<String, dynamic> payload) async {
    await DioClient.instance.post(ApiEndpoints.students, data: payload);
  }

  Future<void> createBatch(Map<String, dynamic> payload) async {
    await DioClient.instance.post(ApiEndpoints.batches, data: payload);
  }

  Future<void> createSession(Map<String, dynamic> payload) async {
    await DioClient.instance.post(ApiEndpoints.sessions, data: payload);
  }

  Future<void> assignCoach(Map<String, dynamic> payload) async {
    await DioClient.instance.post(ApiEndpoints.sessionAssignments, data: payload);
  }
}
