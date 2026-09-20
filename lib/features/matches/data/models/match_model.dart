class MatchModel {
  const MatchModel({
    required this.matchId,
    required this.title,
    required this.date,
    required this.status,
  });

  final int matchId;
  final String title;
  final String date;
  final String status;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['match_id'] as int,
      title: json['title'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }
}
