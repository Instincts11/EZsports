class AttendanceMarkModel {
  const AttendanceMarkModel({required this.date, required this.status, this.batchName = ''});

  final String date;
  final String batchName;
  final String status;

  factory AttendanceMarkModel.fromJson(Map<String, dynamic> json) {
    return AttendanceMarkModel(
      date: json['date']?.toString() ?? '',
      batchName: json['batch_name'] as String? ?? '',
      status: (json['status'] as String? ?? '').toLowerCase(),
    );
  }
}

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
    this.attendanceStatus = '',
    this.billAmount = '',
    this.billDueDate = '',
    this.billStatus = '',
    this.attendanceMarks = const <AttendanceMarkModel>[],
    this.coachNote = '',
    this.mobile = '',
    this.email = '',
    this.guardianName = '',
    this.position = '',
    this.preferredFoot = '',
    this.school = '',
    this.schoolClass = '',
    this.jersey = '',
    this.bloodGroup = '',
    this.allergies = '',
    this.checkedIn = false,
    this.skipReason = '',
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
  final String attendanceStatus;
  final String billAmount;
  final String billDueDate;
  final String billStatus;
  final List<AttendanceMarkModel> attendanceMarks;
  final String coachNote;
  final String mobile;
  final String email;
  final String guardianName;
  final String position;
  final String preferredFoot;
  final String school;
  final String schoolClass;
  final String jersey;
  final String bloodGroup;
  final String allergies;
  final bool checkedIn;
  final String skipReason;

  bool get feeDue {
    final String status = (billStatus.isNotEmpty ? billStatus : feeStatus).toLowerCase();
    return status == 'due' || status == 'overdue';
  }

  String get feeLine {
    if (billAmount.isEmpty) {
      return feeDue ? 'fee due' : '';
    }
    final String due = billDueDate.isEmpty ? '' : ' due $billDueDate';
    return '₹$billAmount$due';
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] as String? ?? '';
    return StudentModel(
      studentId: json['student_id'] as int? ?? 0,
      name: name,
      initials: _initialsFrom(name),
      parentMobile: json['parent_mobile'] as String? ?? json['mobile'] as String? ?? '',
      feeStatus: (json['fee_status'] as String? ?? 'paid').toLowerCase(),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender'] as String? ?? '',
      emergency: json['emergency_contact'] as String? ?? '',
      batchName: json['batch_name'] as String? ?? '',
      attended: json['attended'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      attendanceStatus: json['attendance_status'] as String? ?? '',
      billAmount: json['bill_amount']?.toString() ?? '',
      billDueDate: json['bill_due_date']?.toString() ?? '',
      billStatus: (json['bill_status'] as String? ?? '').toLowerCase(),
      coachNote: json['coach_note'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String? ?? '',
      guardianName: json['guardian_name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      preferredFoot: json['preferred_foot'] as String? ?? '',
      school: json['school'] as String? ?? '',
      schoolClass: json['school_class'] as String? ?? '',
      jersey: json['jersey'] as String? ?? '',
      bloodGroup: json['blood_group'] as String? ?? '',
      allergies: json['allergies'] as String? ?? '',
      checkedIn: json['checked_in'] as bool? ?? false,
      skipReason: json['skip_reason'] as String? ?? '',
      attendanceMarks: (json['attendance_marks'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => AttendanceMarkModel.fromJson(item as Map<String, dynamic>))
          .toList(),
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
