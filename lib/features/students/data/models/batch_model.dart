class BatchModel {
  const BatchModel({
    required this.batchId,
    required this.name,
    required this.days,
    required this.studentCount,
  });

  final int batchId;
  final String name;
  final String days;
  final int studentCount;

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batch_id'] as int,
      name: json['name'] as String,
      days: json['days'] as String,
      studentCount: json['student_count'] as int? ?? 0,
    );
  }
}
