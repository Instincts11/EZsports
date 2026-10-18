class OtpRequestModel {
  const OtpRequestModel({
    required this.message,
    required this.mobile,
    required this.expiresInSeconds,
    this.otp,
    this.accessToken,
    this.role,
  });

  final String message;
  final String mobile;
  final int expiresInSeconds;
  final String? otp;
  final String? accessToken;
  final String? role;

  factory OtpRequestModel.fromJson(Map<String, dynamic> json) {
    return OtpRequestModel(
      message: json['message'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 0,
      otp: json['otp'] as String?,
      accessToken: json['access_token'] as String?,
      role: json['role'] as String?,
    );
  }
}
