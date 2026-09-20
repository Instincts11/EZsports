class StudentModel {
  const StudentModel({
    required this.studentId,
    required this.name,
    required this.parentMobile,
    required this.feeStatus,
  });

  final int studentId;
  final String name;
  final String parentMobile;
  final String feeStatus;

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['student_id'] as int,
      name: json['name'] as String,
      parentMobile: json['parent_mobile'] as String? ?? '',
      feeStatus: json['fee_status'] as String? ?? 'paid',
    );
  }
}
