import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/auth/data/models/otp_request_model.dart';
import 'package:ezsports/features/auth/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel> login({required String identifier, required String password}) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.login,
      data: <String, String>{'identifier': identifier, 'password': password},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> me() async {
    final response = await DioClient.instance.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OtpRequestModel> sendLoginPassword(String email) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.loginSendPassword,
      data: <String, String>{'email': email},
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    return OtpRequestModel(
      message: data['message'] as String? ?? 'Password sent. Enter it from your email.',
      mobile: email,
      expiresInSeconds: 0,
      accessToken: data['access_token'] as String?,
      role: data['role'] as String?,
    );
  }

  Future<OtpRequestModel> requestLoginOtp(String mobile) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.loginRequestOtp,
      data: <String, String>{'mobile': mobile},
    );
    return OtpRequestModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> verifyLoginOtp({required String mobile, required String otp}) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.loginVerifyOtp,
      data: <String, String>{'mobile': mobile, 'otp': otp},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OtpRequestModel> requestSignupOtp(Map<String, dynamic> payload) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.signupRequestOtp,
      data: payload,
    );
    return OtpRequestModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> verifySignupOtp({required String mobile, required String otp}) async {
    final response = await DioClient.instance.post(
      ApiEndpoints.signupVerifyOtp,
      data: <String, String>{'mobile': mobile, 'otp': otp},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await DioClient.instance.post(
      ApiEndpoints.changePassword,
      data: <String, String>{'current_password': currentPassword, 'new_password': newPassword},
    );
  }
}
