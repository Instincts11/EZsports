import 'package:ezsports/core/utils/api_time.dart';

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
    this.date,
    this.ground = '',
    this.note = '',
    this.meetingPoint = '',
    this.focus = '',
    this.kit = '',
    this.myAttendanceStatus,
    this.studentsMarked = 0,
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
  final DateTime? date;
  final String ground;
  final String note;
  final String meetingPoint;
  final String focus;
  final String kit;
  final String? myAttendanceStatus;
  final int studentsMarked;

  String get timeRange => '$start to $end';

  bool get attendanceOpen => studentCount > 0 && studentsMarked < studentCount;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final String rawDate = json['date']?.toString() ?? '';
    final DateTime? date = parseApiDate(rawDate);
    final String rawStart = json['start']?.toString() ?? '';
    final String rawEnd = json['end']?.toString() ?? '';
    final String start = formatApiTime(rawStart);
    final String end = formatApiTime(rawEnd);
    return SessionModel(
      sessionId: json['session_id'] as int? ?? 0,
      batchName: json['batch_name'] as String? ?? '',
      dateLabel: date == null ? rawDate : '${date.day} ${_month(date)} ${_weekday(date)}',
      dayNumber: date == null ? '' : ordinalDay(date.day),
      monthLabel: date == null ? '' : _month(date).toUpperCase(),
      weekdayLabel: date == null ? '' : _weekday(date).toUpperCase(),
      start: start,
      end: end,
      studentCount: json['student_count'] as int? ?? 0,
      batchId: json['batch_id'] as int?,
      date: date,
      ground: json['ground'] as String? ?? '',
      note: json['note'] as String? ?? '',
      meetingPoint: json['meeting_point'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      kit: json['kit'] as String? ?? '',
      myAttendanceStatus: json['my_attendance_status'] as String?,
      studentsMarked: json['students_marked'] as int? ?? 0,
      status: date == null ? 'upcoming' : sessionStatusFor(date, rawStart, rawEnd),
    );
  }

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _weekdays = <String>[
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static String _month(DateTime date) => _months[date.month - 1];

  static String _weekday(DateTime date) => _weekdays[date.weekday - 1];
}
