import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';

class HomeDashboardModel {
  const HomeDashboardModel({
    required this.academyName,
    required this.sessionsToday,
    required this.date,
    required this.upcomingSessions,
    this.notice = '',
    this.phone = '',
    this.address = '',
    this.rangeStart = '',
    this.rangeEnd = '',
    this.attendanceDays = 0,
    this.attended = 0,
    this.missed = 0,
  });

  final String academyName;
  final String notice;
  final String phone;
  final String address;
  final String rangeStart;
  final String rangeEnd;
  final int sessionsToday;
  final String date;
  final List<SessionModel> upcomingSessions;
  final int attendanceDays;
  final int attended;
  final int missed;

  String get dateLabel => formatApiDate(date);

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessions = json['upcoming_sessions'] as List<dynamic>? ?? <dynamic>[];
    final Map<String, dynamic> attendance = json['attendance'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return HomeDashboardModel(
      attendanceDays: attendance['days'] as int? ?? 0,
      attended: attendance['attended'] as int? ?? 0,
      missed: attendance['missed'] as int? ?? 0,
      academyName: json['academy_name'] as String? ?? '',
      sessionsToday: json['sessions_today'] as int? ?? sessions.length,
      date: json['date']?.toString() ?? '',
      upcomingSessions: sessions
          .map((dynamic item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      notice: json['notice'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rangeStart: json['range_start']?.toString() ?? '',
      rangeEnd: json['range_end']?.toString() ?? '',
    );
  }
}
