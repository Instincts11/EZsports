import 'package:ezsports/core/storage/app_store.dart';
import 'package:ezsports/core/widgets/notification_prefs_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Done keeps the latest notification choices', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppStore.init();

    Future<void> open() async {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return const Dialog(
                        child: NotificationPrefsSheet(
                          role: 'coach',
                          accent: Color(0xFFE25B45),
                          ink: Color(0xFF12110F),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await open();
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Session reminders')).value, isTrue);
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Fixture updates')).value, isTrue);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Session reminders'));
    await tester.pump();
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Session reminders')).value, isFalse);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Session reminders'), findsNothing);

    await open();
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Session reminders')).value, isFalse);
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Fixture updates')).value, isTrue);
  });
}
