import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';

class ClassesRepository {
  Future<List<SessionModel>> fetchSessions({String? dateFrom, String? dateTo}) async {
    final response = await DioClient.instance.get(
      ApiEndpoints.sessions,
      queryParameters: <String, String>{
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((dynamic item) => SessionModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
