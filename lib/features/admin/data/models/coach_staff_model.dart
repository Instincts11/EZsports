class CoachStaffModel {
  const CoachStaffModel({required this.coachId, required this.name});

  final int coachId;
  final String name;

  factory CoachStaffModel.fromJson(Map<String, dynamic> json) {
    return CoachStaffModel(coachId: json['coach_id'] as int, name: json['name'] as String);
  }
}
