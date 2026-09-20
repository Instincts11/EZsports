class SessionModel {
  const SessionModel({
    required this.sessionId,
    required this.batchName,
    required this.date,
    required this.start,
    required this.end,
    required this.studentCount,
  });

  final int sessionId;
  final String batchName;
  final String date;
  final String start;
  final String end;
  final int studentCount;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id'] as int,
      batchName: json['batch_name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      studentCount: json['student_count'] as int? ?? 0,
    );
  }
}
