class UserModel {
  const UserModel({
    required this.accessToken,
    required this.role,
    this.userId,
    this.email,
    this.name,
    this.mobile,
    this.academyName,
  });

  final String accessToken;
  final String role;
  final int? userId;
  final String? email;
  final String? name;
  final String? mobile;
  final String? academyName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['access_token'] as String? ?? '',
      role: json['role'] as String? ?? '',
      userId: json['user_id'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
      academyName: json['academy_name'] as String?,
    );
  }
}
