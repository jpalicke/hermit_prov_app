// ABOUTME: Widget tests for the Suggestion Bank screen (CRUD management UI).
// ABOUTME: Covers add, edit, delete, validation blocking, and built-in exclusion.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/crash/no_op_crash_report_service.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/features/prompts/custom_prompts_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrapWithServices(Widget child, {InMemoryPromptRepository? repo}) {
  return AppServices(
    promptRepository: repo ?? InMemoryPromptRepository(),
    drillSettingsRepository: InMemoryDrillSettingsRepository(),
    practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
    journalRepository: InMemoryJournalRepository(),
    appPreferencesRepository: InMemoryAppPreferencesRepository(),
    ttsService: FakeTtsService(),
    crashReportService: const NoOpCrashReportService(),
    child: MaterialApp(home: child),
  );
}

/// Counts how many times [getCustomPrompts] is called so the guard test can
/// verify it fires only once across multiple didChangeDependencies invocations.
class _CountingPromptRepository extends InMemoryPromptRepository {
  int getCustomPromptsCallCount = 0;

  @override
  Future<List<CustomPrompt>> getCustomPrompts({
    PromptCategory? category,
  }) async {
    getCustomPromptsCallCount++;
    return super.getCustomPrompts(category: category);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Test 1: Suggestion bank screen reachable from Tools screen ──────────────
  group('navigation', () {
    testWidgets('Suggestion bank screen is reachable from Tools screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const ToolsScreen()));
      await tester.pumpAndSettle();

      // Tools screen must have an entry for adding words to the suggestion bank
      expect(find.text('Add words to the suggestion bank'), findsOneWidget);
      await tester.tap(find.text('Add words to the suggestion bank'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomPromptsScreen), findsOneWidget);
    });
  });

  // ── Test 2: Valid custom prompt can be added ────────────────────────────────
  group('add', () {
    testWidgets('valid custom prompt can be added and appears in the list',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const CustomPromptsScreen()));
      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in text field
      await tester.enterText(find.byType(TextField).first, 'a rubber duck');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('a rubber duck'), findsOneWidget);
    });
  });

  // ── Test 3: Custom prompt can be edited ────────────────────────────────────
  group('edit', () {
    testWidgets('custom prompt can be edited', (WidgetTester tester) async {
      final repo = InMemoryPromptRepository();
      await repo.addCustomPrompt(CustomPrompt(
        id: 'test-edit-1',
        text: 'original prompt',
        category: PromptCategory.objects,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      await tester.pumpWidget(
          _wrapWithServices(const CustomPromptsScreen(), repo: repo));
      await tester.pumpAndSettle();

      // Tap edit icon on the prompt
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Clear and enter new text
      final textField = find.byType(TextField).first;
      await tester.tap(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, 'updated prompt');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('updated prompt'), findsOneWidget);
      expect(find.text('original prompt'), findsNothing);
    });
  });

  // ── Test 4: Custom prompt can be deleted ───────────────────────────────────
  group('delete', () {
    testWidgets('custom prompt can be deleted with confirmation',
        (WidgetTester tester) async {
      final repo = InMemoryPromptRepository();
      await repo.addCustomPrompt(CustomPrompt(
        id: 'test-del-1',
        text: 'to be deleted',
        category: PromptCategory.objects,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

      await tester.pumpWidget(
          _wrapWithServices(const CustomPromptsScreen(), repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('to be deleted'), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Confirmation dialog — tap Delete to confirm
      expect(find.text('Delete'), findsWidgets);
      // Find the dialog's Delete button specifically
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('to be deleted'), findsNothing);
    });
  });

  // ── Test 5: Blocked prompt shows generic error ─────────────────────────────
  group('validation', () {
    testWidgets('blocked prompt shows error message and is not listed',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const CustomPromptsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter a prompt that contains a blocked slur
      await tester.enterText(
          find.byType(TextField).first, 'a nigger in the park');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            "This prompt can't be saved because it violates content rules."),
        findsOneWidget,
      );
      // The save/edit screen should still be open (not navigated back)
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  // ── Test 6: Built-in prompts are not shown as editable ────────────────────
  group('built-in prompts', () {
    testWidgets('built-in prompts are not shown in the custom prompts screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const CustomPromptsScreen()));
      await tester.pumpAndSettle();

      // When there are no custom prompts, no edit/delete icons should appear
      // (built-ins are never shown here)
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });

  // ── Test 7: _loadPrompts fires only once despite repeated didChangeDependencies
  group('initialization guard', () {
    testWidgets(
        'repo is queried only once when InheritedWidget ancestors rebuild',
        (WidgetTester tester) async {
      final repo = _CountingPromptRepository();

      // Initial render -- wraps in a MediaQuery we can later change to force
      // didChangeDependencies to fire a second time.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
          child: AppServices(
            promptRepository: repo,
            drillSettingsRepository: InMemoryDrillSettingsRepository(),
            practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
            journalRepository: InMemoryJournalRepository(),
            appPreferencesRepository: InMemoryAppPreferencesRepository(),
            ttsService: FakeTtsService(),
            crashReportService: const NoOpCrashReportService(),
            child: const MaterialApp(home: CustomPromptsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.getCustomPromptsCallCount, 1);

      // Rebuild with a different MediaQueryData to trigger didChangeDependencies
      // on any widget that depends on MediaQuery.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: AppServices(
            promptRepository: repo,
            drillSettingsRepository: InMemoryDrillSettingsRepository(),
            practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
            journalRepository: InMemoryJournalRepository(),
            appPreferencesRepository: InMemoryAppPreferencesRepository(),
            ttsService: FakeTtsService(),
            crashReportService: const NoOpCrashReportService(),
            child: const MaterialApp(home: CustomPromptsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Guard must prevent a second repo read.
      expect(repo.getCustomPromptsCallCount, 1);
    });
  });
}
