class LeaveModel {
  const LeaveModel({
    required this.leaveId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
  });

  final int leaveId;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveId: json['leave_id'] as int? ?? 0,
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
