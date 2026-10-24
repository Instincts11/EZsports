import 'package:flutter/foundation.dart';

final class AppEnv {
  AppEnv._();

  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// On Flutter web, call the same host as the app so `/api/...` is proxied by
  /// [web_dev_config.yaml] and shows in Chrome Network under Flutter localhost.
  /// Native builds talk to the API port directly.
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return 'http://127.0.0.1:8000';
  }
}
