// ABOUTME: Widget tests for the Practice home screen (Choose Your Drill).
// ABOUTME: Verifies drill cards appear, direct-to-session navigation, and gear icon for configure.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/character_creation/character_creation_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/five_line/five_line_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_configure_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

void main() {
  // Pump the app wrapped with AppServices (mirrors production main.dart).
  Future<void> pumpPracticeHome(WidgetTester tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(child: const HermitProvApp()),
    );
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

    // ── Navigation: card tap goes directly to session ─────────

    testWidgets('tapping Cat/Clock card navigates directly to session shell',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Cat/Clock');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
      expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
    });

    testWidgets(
        'tapping Character Creation card navigates directly to session shell',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Character Creation');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
      expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
    });

    testWidgets(
        'tapping Two-Character Scenes card navigates directly to session shell',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Two-Character Scenes');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
      expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
    });

    testWidgets('tapping A-to-C card navigates directly to session shell',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'A-to-C / Bad Idea / Initiation');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
      expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
    });

    testWidgets(
        'tapping Five Line Game Drill card navigates directly to session',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Five Line Game Drill');
      // Five Line defaults to manual mode (no shell), just verify it navigated.
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Manual mode shows the Stop / End button.
      expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
    });

    testWidgets('tapping Tools card navigates to the Tools screen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tapCard(tester, 'Tools');
      expect(find.byType(ToolsScreen), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────
  // Gear icon on each drill card opens configure screen
  // ──────────────────────────────────────────────────────────

  group('Gear icon on drill cards opens configure screen', () {
    testWidgets('Cat/Clock gear icon opens CatClockConfigureScreen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tester.ensureVisible(
          find.byKey(const Key('drill_card_configure_catClock'),
              skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drill_card_configure_catClock')));
      await tester.pumpAndSettle();
      expect(find.byType(CatClockConfigureScreen), findsOneWidget);
    });

    testWidgets(
        'Character Creation gear icon opens CharacterCreationConfigureScreen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tester.ensureVisible(
          find.byKey(const Key('drill_card_configure_characterCreation'),
              skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(
          find.byKey(const Key('drill_card_configure_characterCreation')));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterCreationConfigureScreen), findsOneWidget);
    });

    testWidgets(
        'Two-Character Scenes gear icon opens TwoCharacterConfigureScreen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tester.ensureVisible(
          find.byKey(const Key('drill_card_configure_twoCharacterScenes'),
              skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(
          find.byKey(const Key('drill_card_configure_twoCharacterScenes')));
      await tester.pumpAndSettle();
      expect(find.byType(TwoCharacterConfigureScreen), findsOneWidget);
    });

    testWidgets('A-to-C gear icon opens AtoCConfigureScreen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tester.ensureVisible(
          find.byKey(const Key('drill_card_configure_atoC'),
              skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drill_card_configure_atoC')));
      await tester.pumpAndSettle();
      expect(find.byType(AtoCConfigureScreen), findsOneWidget);
    });

    testWidgets('Five Line Game gear icon opens FiveLineConfigureScreen',
        (WidgetTester tester) async {
      await pumpPracticeHome(tester);
      await tester.ensureVisible(
          find.byKey(const Key('drill_card_configure_fiveLineGame'),
              skipOffstage: false));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const Key('drill_card_configure_fiveLineGame')));
      await tester.pumpAndSettle();
      expect(find.byType(FiveLineConfigureScreen), findsOneWidget);
    });
  });
}
