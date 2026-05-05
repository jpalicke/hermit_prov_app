// ABOUTME: Widget tests for the Practice home screen (Choose Your Drill).
// ABOUTME: Verifies drill cards appear, navigation works, and drill start controls are present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

void main() {
  // Pump the app; Practice tab is the default.
  Future<void> pumpPracticeHome(WidgetTester tester) async {
    await tester.pumpWidget(const HermitProvApp());
  }

  // Scroll a card into view then tap it.
  // ListView(children:[...]) builds all children eagerly but paints only the
  // visible portion; ensureVisible scrolls off-screen items into view.
  Future<void> tapCard(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text, skipOffstage: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text, skipOffstage: false));
    await tester.pumpAndSettle();
  }

  // ──────────────────────────────────────────────────────────
  // Cards visible on the Practice home screen
  // ──────────────────────────────────────────────────────────

  group('Practice home cards', () {
    testWidgets('all five drill cards and Tools card appear',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);

      // Use skipOffstage:false because lower cards may be outside the test viewport.
      for (final name in [
        'Cat/Clock',
        'Character Creation',
        'Two-Character Scenes',
        'A-to-C / Bad Idea / Initiation',
        'Five Line Game Drill',
        'Tools',
      ]) {
        expect(find.text(name, skipOffstage: false), findsOneWidget,
            reason: 'Card "$name" not found');
      }
    });

    // ── Navigation: each drill card ───────────────────────────

    testWidgets(
        'tapping Cat/Clock card navigates to its drill start screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Cat/Clock');
      expect(find.byType(DrillStartScreen), findsOneWidget);
      expect(find.text('Cat/Clock'), findsWidgets);
    });

    testWidgets(
        'tapping Character Creation card navigates to its drill start screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Character Creation');
      expect(find.byType(DrillStartScreen), findsOneWidget);
      expect(find.text('Character Creation'), findsWidgets);
    });

    testWidgets(
        'tapping Two-Character Scenes card navigates to its drill start screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Two-Character Scenes');
      expect(find.byType(DrillStartScreen), findsOneWidget);
      expect(find.text('Two-Character Scenes'), findsWidgets);
    });

    testWidgets(
        'tapping A-to-C card navigates to its drill start screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'A-to-C / Bad Idea / Initiation');
      expect(find.byType(DrillStartScreen), findsOneWidget);
      expect(find.text('A-to-C / Bad Idea / Initiation'), findsWidgets);
    });

    testWidgets(
        'tapping Five Line Game Drill card navigates to its drill start screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Five Line Game Drill');
      expect(find.byType(DrillStartScreen), findsOneWidget);
      expect(find.text('Five Line Game Drill'), findsWidgets);
    });

    testWidgets('tapping Tools card navigates to the Tools screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Tools');
      expect(find.byType(ToolsScreen), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────
  // Drill start placeholder controls
  // ──────────────────────────────────────────────────────────

  group('Drill start placeholder controls', () {
    testWidgets('drill start screen shows Start, Configure, and info/help',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Cat/Clock');

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('Character Creation start screen has Start, Configure, info/help',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Character Creation');

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('Two-Character Scenes start screen has Start, Configure, info/help',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Two-Character Scenes');

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('A-to-C start screen has Start, Configure, info/help',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'A-to-C / Bad Idea / Initiation');

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('Five Line Game start screen has Start, Configure, info/help',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Five Line Game Drill');

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
