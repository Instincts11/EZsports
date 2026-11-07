import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponseCache {
  ResponseCache._();

  static const String _prefix = 'ezsports.http.';
  static final Map<String, Object?> _memory = <String, Object?>{};

  static Future<void> load(SharedPreferences preferences) async {
    _memory.clear();
    for (final String key in preferences.getKeys()) {
      if (!key.startsWith(_prefix)) {
        continue;
      }
      final String? raw = preferences.getString(key);
      if (raw == null || raw.isEmpty) {
        continue;
      }
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map || decoded is List) {
          _memory[key.substring(_prefix.length)] = decoded;
        }
      } catch (_) {
        await preferences.remove(key);
      }
    }
  }

  static String keyFor(RequestOptions options) {
    final String path = options.uri.path;
    final String query = options.uri.query;
    return query.isEmpty ? path : '$path?$query';
  }

  static void put(String key, Object? data) {
    if (data is! Map && data is! List) {
      return;
    }
    try {
      final String encoded = jsonEncode(data);
      _memory[key] = jsonDecode(encoded);
      SharedPreferences.getInstance().then((SharedPreferences preferences) {
        preferences.setString('$_prefix$key', encoded);
      });
    } catch (_) {}
  }

  static Future<void> clear() async {
    _memory.clear();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> keys = preferences.getKeys().where((String key) => key.startsWith(_prefix)).toList();
    for (final String key in keys) {
      await preferences.remove(key);
    }
  }

  static T? map<T>(String key, T Function(Map<String, dynamic> json) decode) {
    final Object? value = _memory[key];
    if (value is! Map) {
      return null;
    }
    try {
      final Map<String, dynamic> json = value is Map<String, dynamic> ? value : Map<String, dynamic>.from(value);
      return decode(json);
    } catch (_) {
      return null;
    }
  }

  static List<T>? mapList<T>(String key, T Function(Map<String, dynamic> json) decode) {
    final Object? value = _memory[key];
    if (value is! List) {
      return null;
    }
    try {
      return value.map((dynamic item) {
        final Map<String, dynamic> json = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
        return decode(json);
      }).toList();
    } catch (_) {
      return null;
    }
  }
}
