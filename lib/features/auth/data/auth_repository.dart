import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/auth/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel> login({required String email, required String password}) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.login,
      data: <String, String>{'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> me() async {
    final response = await DioClient.instance.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
