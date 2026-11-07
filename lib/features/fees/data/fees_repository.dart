import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/core/storage/response_cache.dart';

class FeeAccount {
  const FeeAccount({
    required this.kind,
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
  });

  final String kind;
  final int id;
  final String name;
  final String contact;
  final String email;

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+')).where((String part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

class FeeBill {
  const FeeBill({
    required this.billId,
    required this.studentId,
    required this.coachId,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  final int billId;
  final int? studentId;
  final int? coachId;
  final String amount;
  final String dueDate;
  final String status;

  factory FeeBill.fromJson(Map<String, dynamic> json) {
    return FeeBill(
      billId: json['bill_id'] as int? ?? 0,
      studentId: json['student_id'] as int?,
      coachId: json['coach_id'] as int?,
      amount: json['amount']?.toString() ?? '',
      dueDate: (json['due_date'] as String? ?? '').length >= 10
          ? (json['due_date'] as String).substring(0, 10)
          : json['due_date'] as String? ?? '',
      status: (json['status'] as String? ?? 'due').toLowerCase(),
    );
  }
}

class FeesRepository {
  List<FeeAccount> storedPlayers() {
    return ResponseCache.mapList(ApiEndpoints.students, _playerAccount) ?? <FeeAccount>[];
  }

  List<FeeAccount> storedCoaches() {
    return ResponseCache.mapList(ApiEndpoints.coaches, _coachAccount) ?? <FeeAccount>[];
  }

  List<FeeBill> storedBills() {
    return ResponseCache.mapList(ApiEndpoints.bills, FeeBill.fromJson) ?? <FeeBill>[];
  }

  Future<List<FeeAccount>> players() async {
    final response = await DioClient.instance.get(ApiEndpoints.students);
    final List<dynamic> rows = response.data as List<dynamic>? ?? <dynamic>[];
    return rows.map((dynamic row) => _playerAccount(row as Map<String, dynamic>)).toList();
  }

  Future<List<FeeAccount>> coaches() async {
    final response = await DioClient.instance.get(ApiEndpoints.coaches);
    final List<dynamic> rows = response.data as List<dynamic>? ?? <dynamic>[];
    return rows.map((dynamic row) => _coachAccount(row as Map<String, dynamic>)).toList();
  }

  Future<List<FeeBill>> bills() async {
    final response = await DioClient.instance.get(ApiEndpoints.bills);
    final List<dynamic> rows = response.data as List<dynamic>? ?? <dynamic>[];
    return rows.map((dynamic row) => FeeBill.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<FeeBill> save({
    required FeeAccount account,
    required int? billId,
    required String amount,
    required String dueDate,
    required String status,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'amount': num.parse(amount),
      'due_date': dueDate,
      'status': status,
    };
    if (billId == null) {
      if (account.kind == 'player') {
        body['student_id'] = account.id;
      } else {
        body['coach_id'] = account.id;
      }
      final response = await DioClient.instance.post(ApiEndpoints.bills, data: body);
      return FeeBill.fromJson(response.data as Map<String, dynamic>);
    }
    final response = await DioClient.instance.patch('${ApiEndpoints.bills}/$billId', data: body);
    return FeeBill.fromJson(response.data as Map<String, dynamic>);
  }
}

FeeAccount _playerAccount(Map<String, dynamic> json) {
  final String mobile = (json['mobile'] as String? ?? '').trim();
  final String parent = (json['parent_mobile'] as String? ?? '').trim();
  return FeeAccount(
    kind: 'player',
    id: json['student_id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    contact: mobile.isNotEmpty ? mobile : parent,
    email: json['email'] as String? ?? '',
  );
}

FeeAccount _coachAccount(Map<String, dynamic> json) {
  return FeeAccount(
    kind: 'coach',
    id: json['coach_id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    contact: json['mobile'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );
}
