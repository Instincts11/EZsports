import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';

class PlayerSessionModel {
  const PlayerSessionModel({
    required this.session,
    required this.rawDate,
    this.coachName,
    this.coachHeadline,
    this.attendanceStatus,
    this.checkedIn = false,
    this.skipReason,
  });

  final SessionModel session;
  final String rawDate;
  final String? coachName;
  final String? coachHeadline;
  final String? attendanceStatus;
  final bool checkedIn;
  final String? skipReason;

  DateTime? get date => parseApiDate(rawDate);

  bool get skipped => skipReason != null && skipReason!.trim().isNotEmpty;

  String get detail {
    final String coachNameLine = coachName == null || coachName!.trim().isEmpty ? '' : 'Coach ${coachName!}';
    final String headline = coachHeadline == null ? '' : coachHeadline!.trim();
    final String coach = headline.isEmpty || coachNameLine.isEmpty ? coachNameLine : '$coachNameLine, $headline';
    final String count = session.studentCount > 0 ? '${session.studentCount} players' : '';
    final String note = session.note.trim();
    final String meet = session.meetingPoint.trim().isEmpty ? '' : 'Meet at ${session.meetingPoint.trim()}';
    final String focus = session.focus.trim();
    final String kit = session.kit.trim().isEmpty ? '' : 'Kit: ${session.kit.trim()}';
    return <String>[coach, count, meet, focus, kit, note].where((String part) => part.isNotEmpty).join(' · ');
  }

  factory PlayerSessionModel.fromJson(Map<String, dynamic> json) {
    return PlayerSessionModel(
      session: SessionModel.fromJson(json),
      rawDate: json['date']?.toString() ?? '',
      coachName: json['coach_name'] as String?,
      coachHeadline: json['coach_headline'] as String?,
      attendanceStatus: json['attendance_status'] as String?,
      checkedIn: json['checked_in'] as bool? ?? false,
      skipReason: json['skip_reason'] as String?,
    );
  }
}

class PlayerAttendanceModel {
  const PlayerAttendanceModel({required this.label, required this.missed});

  final String label;
  final bool missed;

  factory PlayerAttendanceModel.fromJson(Map<String, dynamic> json) {
    final String date = formatApiDate(json['date']?.toString());
    final String batch = json['batch_name'] as String? ?? '';
    return PlayerAttendanceModel(
      label: batch.isEmpty ? date : '$date · $batch',
      missed: json['status'] == 'absent',
    );
  }
}

class PlayerHomeModel {
  const PlayerHomeModel({
    required this.academyName,
    required this.playerName,
    required this.date,
    required this.sessionsToday,
    required this.feeStatus,
    required this.days,
    required this.attended,
    required this.missed,
    required this.todaySessions,
    required this.upcomingSessions,
    required this.matches,
    this.notice = '',
    this.phone = '',
    this.address = '',
    this.feeAmount,
    this.feeDueDate,
  });

  final String academyName;
  final String playerName;
  final String date;
  final int sessionsToday;
  final String feeStatus;
  final String? feeAmount;
  final String? feeDueDate;
  final int days;
  final int attended;
  final int missed;
  final List<PlayerSessionModel> todaySessions;
  final List<PlayerSessionModel> upcomingSessions;
  final List<MatchModel> matches;
  final String notice;
  final String phone;
  final String address;

  factory PlayerHomeModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> attendance = json['attendance'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PlayerHomeModel(
      academyName: json['academy_name'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
      date: json['date']?.toString() ?? '',
      sessionsToday: json['sessions_today'] as int? ?? 0,
      feeStatus: json['fee_status'] as String? ?? '',
      feeAmount: json['fee_amount']?.toString(),
      feeDueDate: json['fee_due_date']?.toString(),
      days: attendance['days'] as int? ?? 0,
      attended: attendance['attended'] as int? ?? 0,
      missed: attendance['missed'] as int? ?? 0,
      todaySessions: _sessions(json['today_sessions']),
      upcomingSessions: _sessions(json['upcoming_sessions']),
      matches: _matches(json['matches']),
      notice: json['notice'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  static List<PlayerSessionModel> _sessions(Object? raw) {
    if (raw is! List) {
      return const <PlayerSessionModel>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PlayerSessionModel.fromJson)
        .toList();
  }

  static List<MatchModel> _matches(Object? raw) {
    if (raw is! List) {
      return const <MatchModel>[];
    }
    return raw.whereType<Map<String, dynamic>>().map(MatchModel.fromJson).toList();
  }
}
