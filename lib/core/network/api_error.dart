import 'package:dio/dio.dart';

String apiErrorMessage(Object error, String fallback) {
  if (error is DioException && error.response?.data is Map<String, dynamic>) {
    final Object? detail = (error.response!.data as Map<String, dynamic>)['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
  }
  return fallback;
}
