import 'package:ezsports/core/config/app_router.dart';
import 'package:ezsports/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<Size> phoneSizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
    Size(430, 932),
  ];

  for (final Size size in phoneSizes) {
    testWidgets('player and coach fit ${size.width.toInt()}x${size.height.toInt()}', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      AppRouter.router.go('/login');
      await tester.pumpWidget(const ProviderScope(child: EzSportsApp()));
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Continue as player'));
      await tester.pumpAndSettle();
      expect(find.text('Advaita S'), findsOneWidget);

      await _tapVisible(tester, find.text('Skip session'));
      await tester.pumpAndSettle();
      expect(find.text('Unwell'), findsOneWidget);
      await tester.tap(find.text('Unwell'));
      await tester.pumpAndSettle();
      expect(find.text('Skipped'), findsWidgets);
      expect(tester.takeException(), isNull);

      await _tapVisible(tester, find.text('Fixtures'));
      await tester.pumpAndSettle();
      expect(find.text('Kochi United'), findsWidgets);

      await _tapVisible(tester, find.text('Schedule'));
      await tester.pumpAndSettle();
      expect(find.text('YOUR SESSION'), findsOneWidget);

      await _tapVisible(tester, find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Advaita'), findsOneWidget);
      expect(tester.takeException(), isNull);

      AppRouter.router.go('/login');
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Continue as coach'));
      await tester.pumpAndSettle();
      expect(find.text("Today's sessions"), findsOneWidget);

      await _tapVisible(tester, find.text('Fixtures'));
      await tester.pumpAndSettle();
      expect(find.text('Academy Cup'), findsWidgets);

      await _tapVisible(tester, find.text('Players'));
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Sessions'));
      await tester.pumpAndSettle();
      expect(find.text('Upcoming'), findsOneWidget);

      await _tapVisible(tester, find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('R. Nair'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(finder);
}
