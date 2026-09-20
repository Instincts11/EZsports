class BillModel {
  const BillModel({
    required this.billId,
    required this.studentId,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  final int billId;
  final int studentId;
  final String amount;
  final String dueDate;
  final String status;

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      billId: json['bill_id'] as int,
      studentId: json['student_id'] as int,
      amount: json['amount'].toString(),
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
    );
  }
}
