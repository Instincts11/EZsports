class BatchModel {
  const BatchModel({
    required this.batchId,
    required this.name,
    required this.days,
    required this.studentCount,
    this.timeRange = '',
    this.pitch = '',
    this.capacity = 0,
    this.meetingPoint = '',
    this.focus = '',
    this.kit = '',
  });

  final int batchId;
  final String name;
  final String days;
  final int studentCount;
  final String timeRange;
  final String pitch;
  final int capacity;
  final String meetingPoint;
  final String focus;
  final String kit;

  String get placeLine {
    if (timeRange.isEmpty) {
      return pitch;
    }
    if (pitch.isEmpty) {
      return timeRange;
    }
    return '$timeRange · $pitch';
  }

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batch_id'] as int,
      name: json['name'] as String,
      days: json['days'] as String,
      studentCount: json['student_count'] as int? ?? 0,
      meetingPoint: json['meeting_point'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      kit: json['kit'] as String? ?? '',
    );
  }
}
