import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/network/dio_client.dart';
import 'package:ezsports/features/home/data/models/home_dashboard_model.dart';

class HomeRepository {
  Future<HomeDashboardModel> fetchDashboard() async {
    final response = await DioClient.instance.get(ApiEndpoints.home);
    return HomeDashboardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
