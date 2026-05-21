// ABOUTME: Widget tests for the tools-only web app shell.
// ABOUTME: Verifies ToolsScreen mounts correctly and bottom nav is absent.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/web/web_app.dart';

void main() {
  group('HermitProvWebApp', () {
    testWidgets('mounts and shows ToolsScreen', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pumpAndSettle();

      expect(find.text('Tools'), findsOneWidget);
    });

    testWidgets('shows all five tool tiles', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pumpAndSettle();

      expect(find.text('Suggestion Generator'), findsOneWidget);
      expect(find.text('Add words to the suggestion bank'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Emotion Wheel'), findsOneWidget);
    });

    testWidgets('does not show BottomNavigationBar', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('can navigate into Suggestion Generator', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Suggestion Generator'));
      await tester.pumpAndSettle();

      expect(find.text('New Prompt'), findsOneWidget);
    });

    testWidgets('can navigate into Timer', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();

      // Timer screen has a start button.
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('can navigate into Emotion Wheel', (tester) async {
      await tester.pumpWidget(const HermitProvWebApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Emotion Wheel'));
      await tester.pumpAndSettle();

      expect(find.text('Pick random emotion'), findsOneWidget);
    });

    // Journal and "Add words to the suggestion bank" are also present in the web build.
    // Their data is backed by in-memory repositories: entries are lost on page refresh.
  });
}
