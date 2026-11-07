import 'package:ezsports/core/storage/app_store.dart';
import 'package:ezsports/core/storage/response_cache.dart';

final class AuthSession {
  AuthSession._();

  static const String _tokenKey = 'ezsports.token';
  static const String _roleKey = 'ezsports.role';
  static const String _pathKey = 'ezsports.path';

  static String? _token;
  static String? _role;

  static Future<void> init() async {
    await AppStore.init();
    _token = AppStore.preferences?.getString(_tokenKey);
    _role = AppStore.preferences?.getString(_roleKey);
  }

  static String? get roleSync => _role;

  static Future<void> save({required String token, required String role}) async {
    _token = token;
    _role = role;
    await AppStore.preferences?.setString(_tokenKey, token);
    await AppStore.preferences?.setString(_roleKey, role);
    await AppStore.preferences?.remove(_pathKey);
    await ResponseCache.clear();
  }

  static Future<String?> get token async => _token;

  static Future<String?> get role async => _role;

  static Future<void> clear() async {
    _token = null;
    _role = null;
    await AppStore.preferences?.remove(_tokenKey);
    await AppStore.preferences?.remove(_roleKey);
    await AppStore.preferences?.remove(_pathKey);
    await ResponseCache.clear();
  }

  static String startLocation() {
    final String? role = _role;
    if (role == null || role.isEmpty) {
      return '/login';
    }
    final String? saved = AppStore.preferences?.getString(_pathKey);
    if (saved != null && allows(role, saved)) {
      return saved;
    }
    return homeFor(role);
  }

  static String homeFor(String? role) {
    switch (role) {
      case 'coach':
        return '/home';
      case 'player':
        return '/player/home';
      case 'accountant':
        return '/accountant';
      default:
        return '/login';
    }
  }

  static bool allows(String? role, String path) {
    switch (role) {
      case 'coach':
        return path == '/home' ||
            path.startsWith('/batches') ||
            path.startsWith('/players') ||
            path.startsWith('/sessions') ||
            path.startsWith('/profile');
      case 'player':
        return path.startsWith('/player');
      case 'accountant':
        return path.startsWith('/accountant');
      default:
        return false;
    }
  }

  static void rememberPath(String path) {
    if (!allows(_role, path)) {
      return;
    }
    AppStore.preferences?.setString(_pathKey, path);
  }
}
