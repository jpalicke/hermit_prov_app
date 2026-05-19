// ABOUTME: Smoke tests for basic accessibility requirements across the app.
// ABOUTME: Verifies app launches cleanly and BottomNavigationBar tabs have semantic labels.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';

Widget _wrapApp() => AppServices.withInMemory(child: const HermitProvApp());

void main() {
  group('Accessibility smoke tests', () {
    testWidgets('app launches without exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapApp());
      // Verify the app rendered without throwing.
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('BottomNavigationBar has semantic labels for all 3 tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapApp());

      final nav = find.byType(BottomNavigationBar);
      expect(nav, findsOneWidget);

      // All three tab labels must be present in the nav bar.
      expect(
        find.descendant(of: nav, matching: find.text('Practice')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('History')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Settings')),
        findsOneWidget,
      );
    });

    testWidgets('BottomNavigationBar items carry semantic labels via text',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapApp());

      // Verify each BottomNavigationBarItem label text is accessible.
      final semanticsHandle = tester.ensureSemantics();

      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      semanticsHandle.dispose();
    });
  });
}
