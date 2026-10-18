import 'package:ezsports/core/config/app_router.dart';
import 'package:ezsports/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('player shell matches the academy screens', (WidgetTester tester) async {
    AppRouter.router.go('/login');
    await tester.pumpWidget(const ProviderScope(child: EzSportsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as player'));
    await tester.pumpAndSettle();
    expect(find.text('Advaita S'), findsOneWidget);
    expect(find.text('My attendance'), findsOneWidget);
    expect(find.text("I'm here"), findsWidgets);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('My fixtures'), findsOneWidget);
    expect(find.text('Kochi United'), findsWidgets);

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.text('YOUR SESSION'), findsOneWidget);
    expect(find.text('Skip session'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Advaita'), findsOneWidget);

    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();
    expect(find.text('Missed'), findsWidgets);

    await tester.tap(find.text('Fixtures').first);
    await tester.pumpAndSettle();
    expect(find.text('Kochi United'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coach shell matches the academy screens', (WidgetTester tester) async {
    AppRouter.router.go('/login');
    await tester.pumpWidget(const ProviderScope(child: EzSportsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as coach'));
    await tester.pumpAndSettle();
    expect(find.text("Today's sessions"), findsOneWidget);
    expect(find.text('Weekend Morning'), findsOneWidget);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('3 matches · 1 lineup still open'), findsOneWidget);
    expect(find.text('Academy Cup'), findsWidgets);

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('View players'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('R. Nair'), findsOneWidget);
    expect(find.text('Head coach'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
