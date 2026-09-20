class AttendanceModel {
  const AttendanceModel({required this.id, required this.status});

  final int id;
  final String status;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(id: json['id'] as int, status: json['status'] as String);
  }
}
