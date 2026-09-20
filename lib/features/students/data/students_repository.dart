import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';

class StudentsRepository {
  Future<List<BatchModel>> fetchBatches() async {
    final response = await DioClient.instance.get(ApiEndpoints.batches);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((dynamic item) => BatchModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<StudentModel>> fetchBatchStudents(int batchId) async {
    final response = await DioClient.instance.get(ApiEndpoints.batchStudents(batchId));
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((dynamic item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
