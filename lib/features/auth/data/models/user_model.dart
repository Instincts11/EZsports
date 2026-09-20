class UserModel {
  const UserModel({
    required this.accessToken,
    required this.role,
    this.userId,
    this.email,
    this.name,
  });

  final String accessToken;
  final String role;
  final int? userId;
  final String? email;
  final String? name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['access_token'] as String? ?? '',
      role: json['role'] as String? ?? '',
      userId: json['user_id'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }
}
