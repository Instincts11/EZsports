class CoachProfileModel {
  const CoachProfileModel({
    required this.coachId,
    required this.name,
    required this.mobile,
  });

  final int coachId;
  final String name;
  final String mobile;

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    return CoachProfileModel(
      coachId: json['coach_id'] as int,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
    );
  }
}
