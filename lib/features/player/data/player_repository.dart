import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/data/models/player_profile_model.dart';

class PlayerRepository {
  Future<PlayerHomeModel> getHome() async {
    final response = await DioClient.instance.get(ApiEndpoints.playerHome);
    return PlayerHomeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PlayerSessionModel>> getSessions() async {
    final response = await DioClient.instance.get(ApiEndpoints.playerSessions);
    final List<dynamic> rows = response.data as List<dynamic>;
    return rows.map((dynamic row) => PlayerSessionModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<PlayerSessionModel> respondToSession(int sessionId, {bool? checkedIn, String? skipReason, bool clearSkip = false}) async {
    final response = await DioClient.instance.put(
      ApiEndpoints.playerSessionResponse(sessionId),
      data: <String, dynamic>{
        if (checkedIn != null) 'checked_in': checkedIn,
        if (skipReason != null || clearSkip) 'skip_reason': skipReason,
      },
    );
    return PlayerSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MatchModel>> getMatches() async {
    final response = await DioClient.instance.get(ApiEndpoints.playerMatches);
    final List<dynamic> rows = response.data as List<dynamic>;
    return rows.map((dynamic row) => MatchModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<List<PlayerAttendanceModel>> getAttendance() async {
    final response = await DioClient.instance.get(ApiEndpoints.playerAttendance);
    final List<dynamic> rows = response.data as List<dynamic>;
    return rows.map((dynamic row) => PlayerAttendanceModel.fromJson(row as Map<String, dynamic>)).toList();
  }

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
