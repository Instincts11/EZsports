import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class AuthSession {
  AuthSession._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _roleKey = 'user_role';

  static Future<void> save({required String token, required String role}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> get token async => _storage.read(key: _tokenKey);

  static Future<String?> get role async => _storage.read(key: _roleKey);

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
