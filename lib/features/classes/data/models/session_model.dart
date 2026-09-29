class SessionModel {
  const SessionModel({
    required this.sessionId,
    required this.batchName,
    required this.dateLabel,
    required this.dayNumber,
    required this.monthLabel,
    required this.weekdayLabel,
    required this.start,
    required this.end,
    required this.studentCount,
    this.status = 'upcoming',
    this.batchId,
  });

  final int sessionId;
  final String batchName;
  final String dateLabel;
  final String dayNumber;
  final String monthLabel;
  final String weekdayLabel;
  final String start;
  final String end;
  final int studentCount;
  final String status;
  final int? batchId;

  String get timeRange => '$start to $end';

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id'] as int,
      batchName: json['batch_name'] as String? ?? '',
      dateLabel: json['date'] as String? ?? '',
      dayNumber: '',
      monthLabel: '',
      weekdayLabel: '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      studentCount: json['student_count'] as int? ?? 0,
    );
  }
}
