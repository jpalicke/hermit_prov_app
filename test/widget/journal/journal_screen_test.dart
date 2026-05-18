// ABOUTME: Widget tests for JournalScreen and JournalEntryScreen.
// ABOUTME: Covers navigation from Tools, CRUD operations, empty state, and sort order.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/features/journal/journal_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

Widget _wrapWithServices(Widget child) {
  return AppServices.withInMemory(
    child: MaterialApp(home: child),
  );
}

void main() {
  group('JournalScreen', () {
    testWidgets('journal is reachable from Tools screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const ToolsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('empty state shows when no entries',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const JournalScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'No journal entries yet. Tap + to write your first entry.'),
        findsOneWidget,
      );
    });

    testWidgets('create entry: tap FAB, enter text, save, entry appears in list',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const JournalScreen()));
      await tester.pumpAndSettle();

      // Open create screen via FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField).first, 'My first entry');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.textContaining('My first entry'), findsOneWidget);
    });

    testWidgets(
        'edit entry: tap existing entry, modify text, save, list shows updated text',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const JournalScreen()));
      await tester.pumpAndSettle();

      // Create initial entry
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Original text');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Tap entry to edit
      await tester.tap(find.textContaining('Original text'));
      await tester.pumpAndSettle();

      // Update text
      final bodyField = find.byType(TextField).first;
      await tester.tap(bodyField);
      await tester.pumpAndSettle();
      await tester.enterText(bodyField, 'Updated text');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.textContaining('Updated text'), findsOneWidget);
      expect(find.textContaining('Original text'), findsNothing);
    });

    testWidgets(
        'delete entry: tap entry, tap delete, confirm, entry removed from list',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const JournalScreen()));
      await tester.pumpAndSettle();

      // Create entry
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Entry to delete');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Tap to open edit
      await tester.tap(find.textContaining('Entry to delete'));
      await tester.pumpAndSettle();

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Entry to delete'), findsNothing);
      expect(
        find.text(
            'No journal entries yet. Tap + to write your first entry.'),
        findsOneWidget,
      );
    });

    testWidgets('entries sort newest-first', (WidgetTester tester) async {
      // Pre-seed two entries with distinct dates via the repository.
      // We build the widget tree so we can get AppServices, then seed, then reload.
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (context) {
              services = AppServices.of(context);
              return MaterialApp(home: const JournalScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final older = JournalEntry(
        id: '1',
        body: 'Older entry',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final newer = JournalEntry(
        id: '2',
        body: 'Newer entry',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );

      await services.journalRepository.addEntry(older);
      await services.journalRepository.addEntry(newer);

      // Trigger reload by navigating away then back — simpler: just call pump
      // after a setState trigger. Rebuild the widget to trigger didChangeDependencies.
      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (context) {
              // Reuse the same in-memory repo is impossible from a new withInMemory,
              // so instead we seed again and wrap using the same service instance.
              return MaterialApp(
                home: Builder(
                  builder: (ctx) {
                    return const JournalScreen();
                  },
                ),
              );
            },
          ),
        ),
      );

      // Use a direct approach: build a wrapper that injects the seeded services.
      final seededServices = AppServices(
        journalRepository: services.journalRepository,
        promptRepository: services.promptRepository,
        drillSettingsRepository: services.drillSettingsRepository,
        practiceHistoryRepository: services.practiceHistoryRepository,
        appPreferencesRepository: services.appPreferencesRepository,
        child: const MaterialApp(home: JournalScreen()),
      );

      await tester.pumpWidget(seededServices);
      await tester.pumpAndSettle();

      final listItems = find.byType(ListTile);
      expect(listItems, findsNWidgets(2));

      // The first tile's title should be the newer date (June)
      final firstTileTitle = tester
          .widget<ListTile>(listItems.at(0))
          .title as Text;
      expect(firstTileTitle.data, contains('June'));

      final secondTileTitle = tester
          .widget<ListTile>(listItems.at(1))
          .title as Text;
      expect(secondTileTitle.data, contains('January'));
    });
  });
}
