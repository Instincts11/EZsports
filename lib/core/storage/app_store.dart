import 'package:shared_preferences/shared_preferences.dart';

import 'package:ezsports/core/storage/response_cache.dart';

class AppStore {
  AppStore._();

  static SharedPreferences? preferences;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
    await ResponseCache.load(preferences!);
  }

  static String get feeKind => preferences?.getString('ezsports.feeKind') ?? 'player';

  static void saveFeeKind(String value) {
    preferences?.setString('ezsports.feeKind', value);
  }

  static int get playerTab => preferences?.getInt('ezsports.playerTab') ?? 0;

  static void savePlayerTab(int value) {
    preferences?.setInt('ezsports.playerTab', value);
  }

  static String get sessionFilter => preferences?.getString('ezsports.sessionFilter') ?? 'upcoming';

  static void saveSessionFilter(String value) {
    preferences?.setString('ezsports.sessionFilter', value);
  }

  static DateTime? get rangeStart => DateTime.tryParse(preferences?.getString('ezsports.rangeStart') ?? '');

  static DateTime? get rangeEnd => DateTime.tryParse(preferences?.getString('ezsports.rangeEnd') ?? '');

  static void saveRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      preferences?.remove('ezsports.rangeStart');
      preferences?.remove('ezsports.rangeEnd');
      return;
    }
    preferences?.setString('ezsports.rangeStart', start.toIso8601String());
    preferences?.setString('ezsports.rangeEnd', end.toIso8601String());
  }

  static bool notifySessions(String role) => preferences?.getBool('ezsports.notify.$role.sessions') ?? true;

  static bool notifyFixtures(String role) => preferences?.getBool('ezsports.notify.$role.fixtures') ?? true;

  static bool notifyFees(String role) => preferences?.getBool('ezsports.notify.$role.fees') ?? false;

  static Future<void> saveNotifications({
    required String role,
    required bool sessions,
    required bool fixtures,
    bool? fees,
  }) async {
    await preferences?.setBool('ezsports.notify.$role.sessions', sessions);
    await preferences?.setBool('ezsports.notify.$role.fixtures', fixtures);
    if (fees != null) {
      await preferences?.setBool('ezsports.notify.$role.fees', fees);
    }
  }
}
