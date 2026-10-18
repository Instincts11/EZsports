class PlayerProfileModel {
  const PlayerProfileModel({
    required this.studentId,
    required this.name,
    required this.parentMobile,
    this.userId,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
    this.mobile,
    this.emergencyContact,
    this.guardianName,
    this.position,
    this.preferredFoot,
    this.school,
    this.schoolClass,
    this.jersey,
    this.bloodGroup,
    this.allergies,
    this.photoUrl,
    this.feeStatus,
    this.otpVerifiedAt,
  });

  final int studentId;
  final int? userId;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? gender;
  final String? mobile;
  final String? emergencyContact;
  final String parentMobile;
  final String? guardianName;
  final String? position;
  final String? preferredFoot;
  final String? school;
  final String? schoolClass;
  final String? jersey;
  final String? bloodGroup;
  final String? allergies;
  final String? photoUrl;
  final String? feeStatus;
  final String? otpVerifiedAt;

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      studentId: json['student_id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dob: json['dob']?.toString(),
      gender: json['gender'] as String?,
      mobile: json['mobile'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      parentMobile: json['parent_mobile'] as String? ?? '',
      guardianName: json['guardian_name'] as String?,
      position: json['position'] as String?,
      preferredFoot: json['preferred_foot'] as String?,
      school: json['school'] as String?,
      schoolClass: json['school_class'] as String?,
      jersey: json['jersey'] as String?,
      bloodGroup: json['blood_group'] as String?,
      allergies: json['allergies'] as String?,
      photoUrl: json['photo_url'] as String?,
      feeStatus: json['fee_status'] as String?,
      otpVerifiedAt: json['otp_verified_at']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'dob': dob,
      'gender': gender,
      'mobile': mobile,
      'emergency_contact': emergencyContact,
      'parent_mobile': parentMobile,
      'guardian_name': guardianName,
      'position': position,
      'preferred_foot': preferredFoot,
      'school': school,
      'school_class': schoolClass,
      'jersey': jersey,
      'blood_group': bloodGroup,
      'allergies': allergies,
      'name': name,
    };
  }
}
