import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/profile/data/models/coach_profile_model.dart';

class ProfileRepository {
  Future<CoachProfileModel> fetchProfile() async {
    final response = await DioClient.instance.get(ApiEndpoints.profile);
    return CoachProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
