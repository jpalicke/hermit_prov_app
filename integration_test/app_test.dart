// ABOUTME: Integration tests covering core user flows across the full app shell.
// ABOUTME: Mounts HermitProvApp with in-memory services; tests cross-screen navigation and CRUD.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _app() => AppServices.withInMemory(child: const HermitProvApp());

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App launch', () {
    testWidgets('opens on the Practice tab and shows drill cards',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.textContaining('Cat/Clock'), findsOneWidget);
      expect(find.textContaining('Character Creation'), findsOneWidget);
      expect(find.textContaining('Two-Character Scenes'), findsOneWidget);
    });
  });

  group('Tab navigation', () {
    testWidgets('can switch between all three tabs', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // Go to History tab.
      await _tapTab(tester, 'History');
      expect(find.text('No sessions yet. Complete a drill for at least 30 seconds to start tracking.'),
          findsOneWidget);

      // Go to Settings tab.
      await _tapTab(tester, 'Settings');
      expect(find.text('Appearance'), findsOneWidget);

      // Back to Practice tab.
      await _tapTab(tester, 'Practice');
      expect(find.textContaining('Cat/Clock'), findsOneWidget);
    });
  });

  group('Journal', () {
    testWidgets('create entry: appears in list', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await _tapTab(tester, 'History');

      // Open journal via the Journal card.
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // Create entry via FAB.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'First integration entry');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.textContaining('First integration entry'), findsOneWidget);
    });

    testWidgets('edit entry: updated text appears in list', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await _tapTab(tester, 'History');
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // Create.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Before edit');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Tap entry to edit.
      await tester.tap(find.textContaining('Before edit'));
      await tester.pumpAndSettle();

      final bodyField = find.byType(TextField).first;
      await tester.tap(bodyField);
      await tester.pumpAndSettle();
      await tester.enterText(bodyField, 'After edit');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.textContaining('After edit'), findsOneWidget);
      expect(find.textContaining('Before edit'), findsNothing);
    });

    testWidgets('delete entry: removed from list, empty state returns',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await _tapTab(tester, 'History');
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // Create.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'To be deleted');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Open and delete.
      await tester.tap(find.textContaining('To be deleted'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('To be deleted'), findsNothing);
      expect(find.textContaining('No journal entries yet'), findsOneWidget);
    });
  });

  group('Custom prompts', () {
    testWidgets('create a custom prompt and it appears in the list',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // Navigate to Tools card on Practice screen (may require scroll).
      await tester.scrollUntilVisible(find.text('Tools'), 100.0);
      await tester.tap(find.text('Tools'));
      await tester.pumpAndSettle();

      // Tap the suggestion bank tile.
      await tester.tap(find.text('Add words to the suggestion bank'));
      await tester.pumpAndSettle();

      // Add a custom prompt via FAB.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter text and save (category defaults to Objects).
      await tester.enterText(find.byType(TextField).first, 'A spy in a library');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify prompt appears in the list.
      expect(find.textContaining('A spy in a library'), findsOneWidget);
    });
  });

  group('Settings — Reset All Data', () {
    testWidgets('clearing all data returns journal to empty state', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // Create a journal entry first.
      await _tapTab(tester, 'History');
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Will be erased');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Back to History via the AppBar back button.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Go to Settings and reset all data (tile may require scroll).
      await _tapTab(tester, 'Settings');
      await tester.scrollUntilVisible(
          find.byKey(const Key('reset_all_data_tile')), 200.0);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset_all_data_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete All'));
      await tester.pumpAndSettle();

      // Return to History → Journal and confirm empty state.
      await _tapTab(tester, 'History');
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No journal entries yet'), findsOneWidget);
    });
  });

  group('Cat/Clock session → History', () {
    testWidgets('completing a 30-second session logs it to History', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // Tap the Cat/Clock drill card.
      await tester.tap(find.textContaining('Cat/Clock').first);
      await tester.pumpAndSettle();

      // Start the session.
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();

      // Pump 31 seconds of fake time to clear the 30-second logging threshold.
      for (int i = 0; i < 31; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Stop the session (resets to idle and logs).
      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pump();

      // Exit the drill.
      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pumpAndSettle();

      // Navigate to History tab.
      await _tapTab(tester, 'History');

      expect(find.textContaining('Cat/Clock'), findsWidgets);
      expect(find.text('Sessions'), findsOneWidget);
    });
  });
}
