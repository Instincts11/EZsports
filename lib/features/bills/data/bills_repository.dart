import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/bills/data/models/bill_model.dart';

class BillsRepository {
  Future<List<BillModel>> fetchBills({int? studentId}) async {
    final response = await DioClient.instance.get(
      ApiEndpoints.bills,
      queryParameters: <String, int>{if (studentId != null) 'student_id': studentId},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((dynamic item) => BillModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
