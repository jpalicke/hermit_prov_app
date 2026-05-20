// ABOUTME: Widget tests for the tools-only web app shell.
// ABOUTME: Verifies ToolsScreen mounts correctly and bottom nav is absent.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/web/web_app.dart';

void main() {
  group('HermitProvWebApp', () {
    testWidgets('mounts and shows ToolsScreen', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pump();

      expect(find.text('Tools'), findsOneWidget);
    });

    testWidgets('shows Suggestion Generator, Timer, and Emotion Wheel tiles',
        (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pump();

      expect(find.text('Suggestion Generator'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Emotion Wheel'), findsOneWidget);
    });

    testWidgets('does not show Practice, History, or Settings bottom nav',
        (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pump();

      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.text('Practice'), findsNothing);
      expect(find.text('History'), findsNothing);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('can navigate into Suggestion Generator', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pump();

      await tester.tap(find.text('Suggestion Generator'));
      await tester.pumpAndSettle();

      expect(find.text('New Prompt'), findsOneWidget);
    });

    testWidgets('can navigate into Timer', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pump();

      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();

      // Timer screen has a start button.
      expect(find.text('Start'), findsOneWidget);
    });
  });
}
