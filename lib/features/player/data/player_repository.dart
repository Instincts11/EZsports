import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/player/data/models/player_profile_model.dart';

class PlayerRepository {
  Future<PlayerProfileModel> getProfile() async {
    final response = await DioClient.instance.get(ApiEndpoints.playerProfile);
    return PlayerProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PlayerProfileModel> updateProfile(Map<String, dynamic> payload) async {
    final response = await DioClient.instance.patch(
      ApiEndpoints.playerProfile,
      data: payload,
    );
    return PlayerProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
