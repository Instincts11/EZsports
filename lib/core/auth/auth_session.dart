final class AuthSession {
  AuthSession._();

  static String? _token;
  static String? _role;

  static Future<void> save({required String token, required String role}) async {
    _token = token;
    _role = role;
  }

  static Future<String?> get token async => _token;

  static Future<String?> get role async => _role;

  static Future<void> clear() async {
    _token = null;
    _role = null;
  }
}
