class HomeDashboardModel {
  const HomeDashboardModel({
    required this.academyName,
    required this.sessionsToday,
  });

  final String academyName;
  final int sessionsToday;

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      academyName: json['academy_name'] as String? ?? '',
      sessionsToday: json['sessions_today'] as int? ?? 0,
    );
  }
}
