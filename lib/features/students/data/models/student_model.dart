class StudentModel {
  const StudentModel({
    required this.studentId,
    required this.name,
    required this.initials,
    required this.parentMobile,
    required this.feeStatus,
    this.firstName = '',
    this.lastName = '',
    this.dob = '',
    this.gender = '',
    this.emergency = '',
    this.batchName = '',
    this.attended = 0,
    this.totalSessions = 0,
  });

  final int studentId;
  final String name;
  final String initials;
  final String parentMobile;
  final String feeStatus;
  final String firstName;
  final String lastName;
  final String dob;
  final String gender;
  final String emergency;
  final String batchName;
  final int attended;
  final int totalSessions;

  bool get feeDue => feeStatus == 'due';

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] as String;
    return StudentModel(
      studentId: json['student_id'] as int,
      name: name,
      initials: _initialsFrom(name),
      parentMobile: json['parent_mobile'] as String? ?? '',
      feeStatus: json['fee_status'] as String? ?? 'paid',
    );
  }

  static String _initialsFrom(String name) {
    final List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
