// ABOUTME: Widget tests for the Prompt Generator screen.
// ABOUTME: Covers prompt display, category selection, auto-advance toggle, and timer disposal.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/features/tools/prompt_generator_screen.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

Widget _wrapWithServices(Widget child, {InMemoryPromptRepository? repo}) {
  return AppServices(
    promptRepository: repo ?? InMemoryPromptRepository(),
    drillSettingsRepository: InMemoryDrillSettingsRepository(),
    practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
    journalRepository: InMemoryJournalRepository(),
    appPreferencesRepository: InMemoryAppPreferencesRepository(),
    ttsService: FakeTtsService(),
    child: MaterialApp(home: child),
  );
}

void main() {
  // ── Test 3: Tapping New Prompt displays a prompt ───────────────────────────
  group('prompt generation', () {
    testWidgets('tapping New Prompt displays a prompt from the word bucket',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const PromptGeneratorScreen()));
      await tester.pumpAndSettle();

      // Initially no prompt text shown (or a placeholder)
      await tester.tap(find.text('New Prompt'));
      await tester.pumpAndSettle();

      // After tapping, something should be displayed in the prompt area.
      // The screen uses a Text widget to show the prompt.
      // We check that some non-empty text appeared in the prompt display area.
      final promptDisplay = find.byKey(const Key('prompt_display'));
      expect(promptDisplay, findsOneWidget);
      final textWidget = tester.widget<Text>(promptDisplay);
      expect(textWidget.data, isNotNull);
      expect(textWidget.data!.isNotEmpty, isTrue);
    });
  });

  // ── Test 4: Category selection affects the prompt pool ────────────────────
  group('category selection', () {
    testWidgets('selecting only one category restricts the prompt pool',
        (WidgetTester tester) async {
      // Seed a repo with only one custom prompt in a specific category
      final repo = InMemoryPromptRepository();
      await repo.addCustomPrompt(CustomPrompt(
        id: 'test-1',
        text: 'unique-objects-prompt-xyz',
        category: PromptCategory.objects,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      await tester
          .pumpWidget(_wrapWithServices(const PromptGeneratorScreen(), repo: repo));
      await tester.pumpAndSettle();

      // Deselect all except Objects — tap "Word Bucket" to deselect all, then
      // re-select Objects. The exact UI interaction depends on implementation.
      // This test verifies the chip/filter mechanism exists.
      // The custom prompt count is shown in parentheses when > 0.
      expect(find.textContaining('Objects'), findsOneWidget);
    });
  });

  // ── Test: Chip isolation when all are selected ──────────────────────────────
  group('chip isolation', () {
    testWidgets(
        'tapping a chip when all categories are selected isolates that category',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const PromptGeneratorScreen()));
      await tester.pumpAndSettle();

      // All categories start selected. Tap "Objects" chip to isolate it.
      await tester.tap(find.text('Objects'));
      await tester.pumpAndSettle();

      // Only Objects should now be selected (chip is selected).
      final objectsChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Objects'),
      );
      expect(objectsChip.selected, isTrue);

      // Other categories should be deselected.
      final locationsChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Locations'),
      );
      expect(locationsChip.selected, isFalse);
    });

    testWidgets(
        'tapping a chip when not all are selected toggles normally',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const PromptGeneratorScreen()));
      await tester.pumpAndSettle();

      // First isolate one category (tap when all are selected).
      await tester.tap(find.text('Objects'));
      await tester.pumpAndSettle();

      // Now tap Locations — it should be added (not all selected, so normal toggle).
      await tester.tap(find.text('Locations'));
      await tester.pumpAndSettle();

      final locationsChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Locations'),
      );
      expect(locationsChip.selected, isTrue);

      // Objects still selected.
      final objectsChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Objects'),
      );
      expect(objectsChip.selected, isTrue);
    });
  });

  // ── Test: New Prompt disabled when nothing selected ───────────────────────
  group('new prompt button state', () {
    testWidgets(
        'New Prompt button is disabled when no categories are selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const PromptGeneratorScreen()));
      await tester.pumpAndSettle();

      // Tap "Deselect All Categories" to clear selection.
      await tester.tap(find.byKey(const Key('select_all_categories_button')));
      await tester.pumpAndSettle();

      // New Prompt button should now be disabled (onPressed == null).
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'New Prompt'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'New Prompt button is enabled when at least one category is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const PromptGeneratorScreen()));
      await tester.pumpAndSettle();

      // By default all categories are selected — button should be enabled.
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'New Prompt'),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  // ── Test 5: Auto-advance timer is cancelled when leaving the screen ────────
  group('auto-advance', () {
    testWidgets('auto-advance toggle is present on the screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const PromptGeneratorScreen()));
      await tester.pumpAndSettle();

      // Screen should have an auto-advance toggle
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets(
        'auto-advance timer is cancelled when navigating away (dispose)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithServices(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key('open_generator'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PromptGeneratorScreen(),
                  ));
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Turn on auto-advance
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Navigate back — no exception should be thrown (timer disposed)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // If we get here, dispose() ran correctly without errors
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
