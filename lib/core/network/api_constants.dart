import 'package:ezsports/core/config/app_env.dart';

final class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppEnv.apiBaseUrl;
  static const String apiPrefix = '/api/v1';
}
