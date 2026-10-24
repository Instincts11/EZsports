import 'package:ezsports/core/utils/api_time.dart';

class MatchModel {
  const MatchModel({
    required this.matchId,
    required this.title,
    required this.date,
    required this.status,
    this.opponent = '',
    this.start = '',
    this.end = '',
    this.batchName = '',
    this.venue = '',
    this.result = '',
  });

  final int matchId;
  final String title;
  final String date;
  final String status;
  final String opponent;
  final String start;
  final String end;
  final String batchName;
  final String venue;
  final String result;

  String get opponentLabel => opponent.isNotEmpty ? opponent : title;

  String get kickoff {
    final String day = formatApiDate(date);
    final String time = formatApiTime(start);
    if (day.isEmpty) {
      return time;
    }
    if (time.isEmpty) {
      return day;
    }
    return '$day · $time';
  }

  String get detail {
    final List<String> parts = <String>[
      if (venue.isNotEmpty) venue else if (batchName.isNotEmpty) batchName,
      if (result.isNotEmpty) result,
      formatApiTime(start),
    ].where((String part) => part.isNotEmpty).toList();
    return parts.join(' · ');
  }

  String get lineupLabel {
    switch (status) {
      case 'previous':
        return 'Played';
      case 'ongoing':
        return 'In progress';
      default:
        return 'Lineup open';
    }
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['match_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status'] as String? ?? 'upcoming',
      opponent: json['opponent'] as String? ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      batchName: json['batch_name'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      result: json['result'] as String? ?? '',
    );
  }
}
