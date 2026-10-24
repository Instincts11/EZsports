class CoachProfileModel {
  const CoachProfileModel({
    required this.coachId,
    required this.name,
    required this.mobile,
    this.email = '',
    this.gender = '',
    this.emergencyContact = '',
    this.certifications = '',
    this.experience = '',
    this.address = '',
    this.dob = '',
    this.headline = '',
  });

  final int coachId;
  final String name;
  final String mobile;
  final String email;
  final String gender;
  final String emergencyContact;
  final String certifications;
  final String experience;
  final String address;
  final String dob;
  final String headline;

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+')).where((String part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'C';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    return CoachProfileModel(
      coachId: json['coach_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      emergencyContact: json['emergency_contact'] as String? ?? '',
      certifications: json['certifications'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      address: json['address'] as String? ?? '',
      dob: json['dob']?.toString() ?? '',
      headline: json['headline'] as String? ?? '',
    );
  }
}
