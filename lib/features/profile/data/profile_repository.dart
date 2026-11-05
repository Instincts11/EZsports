import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/profile/data/models/coach_profile_model.dart';
import 'package:ezsports/features/profile/data/models/leave_model.dart';

class ProfileRepository {
  Future<List<LeaveModel>> fetchLeaves() async {
    final response = await DioClient.instance.get(ApiEndpoints.leaves);
    final List<dynamic> rows = response.data as List<dynamic>;
    return rows.map((dynamic row) => LeaveModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<LeaveModel> requestLeave({
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.leaves,
      data: <String, String>{
        'from_date': fromDate,
        'to_date': toDate,
        'reason': reason,
      },
    );
    return LeaveModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CoachProfileModel> fetchProfile() async {
    final response = await DioClient.instance.get(ApiEndpoints.profile);
    return CoachProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CoachProfileModel> updateProfile(Map<String, dynamic> payload) async {
    final response = await DioClient.instance.patch(ApiEndpoints.profile, data: payload);
    return CoachProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
