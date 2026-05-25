// ABOUTME: Widget tests for the Suggestion Bank screen (CRUD management UI).
// ABOUTME: Covers add, edit, delete, validation blocking, and built-in exclusion.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/crash/no_op_crash_report_service.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/features/prompts/custom_prompts_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

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

/// Throws or recovers on [getCustomPrompts] to exercise the error path.
/// When [slowResponse] is true, the successful response is delayed so tests
/// can assert the intermediate loading state before the future completes.
class _ThrowingPromptRepository extends InMemoryPromptRepository {
  int callCount = 0;
  bool shouldThrow = true;
  bool slowResponse = false;

  @override
  Future<List<CustomPrompt>> getCustomPrompts({
    PromptCategory? category,
  }) async {
    callCount++;
    if (shouldThrow) throw Exception('repo unavailable');
    if (slowResponse) await Future<void>.delayed(const Duration(milliseconds: 500));
    return super.getCustomPrompts(category: category);
  }
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
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
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
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
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

  // ── Test 7: Error state when _loadPrompts throws ──────────────────────────
  group('error state', () {
    testWidgets(
        'shows error message and retry button when _loadPrompts throws',
        (WidgetTester tester) async {
      final repo = _ThrowingPromptRepository();
      await tester.pumpWidget(
          _wrapWithServices(const CustomPromptsScreen(), repo: repo));
      await tester.pumpAndSettle();

      // Spinner must be gone — loading is false after the throw.
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Error message widget must be visible.
      expect(find.byKey(const Key('load_error_message')), findsOneWidget);

      // Retry button must be present.
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
    });

    testWidgets(
        'tapping retry re-invokes _loadPrompts and shows list on recovery',
        (WidgetTester tester) async {
      final repo = _ThrowingPromptRepository();
      await repo.addCustomPrompt(CustomPrompt(
        id: 'retry-test-1',
        text: 'recovered prompt',
        category: PromptCategory.objects,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));

      await tester.pumpWidget(
          _wrapWithServices(const CustomPromptsScreen(), repo: repo));
      await tester.pumpAndSettle();

      // First call threw — error state shown.
      expect(repo.callCount, 1);
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);

      // Allow recovery, but delay the response so the spinner is observable.
      repo
        ..shouldThrow = false
        ..slowResponse = true;

      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      // One frame: _loading=true, _error=null — spinner must be visible before
      // the delayed future resolves.
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Repo was called again and prompt list is shown.
      expect(repo.callCount, 2);
      expect(find.text('recovered prompt'), findsOneWidget);
    });

    testWidgets(
        'error state appears when reload after mutation throws',
        (WidgetTester tester) async {
      final repo = _ThrowingPromptRepository()..shouldThrow = false;

      await tester.pumpWidget(
          _wrapWithServices(const CustomPromptsScreen(), repo: repo));
      await tester.pumpAndSettle();

      // Initial load succeeded — no error state.
      expect(find.byKey(const Key('load_error_message')), findsNothing);

      // Repo will throw on the next call (the post-add reload).
      repo.shouldThrow = true;

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'a new prompt');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Post-add reload threw — error state must now be visible.
      expect(find.byKey(const Key('load_error_message')), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
    });
  });

  // ── Test 8: _loadPrompts fires only once despite repeated didChangeDependencies
  group('initialization guard', () {
    testWidgets(
        'repo is queried only once even when didChangeDependencies fires again',
        (WidgetTester tester) async {
      final repo = _CountingPromptRepository();

      // First render — standard AppServices (notifyDependents defaults to false).
      await tester.pumpWidget(
        AppServices(
          promptRepository: repo,
          drillSettingsRepository: InMemoryDrillSettingsRepository(),
          practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
          journalRepository: InMemoryJournalRepository(),
          appPreferencesRepository: InMemoryAppPreferencesRepository(),
          ttsService: FakeTtsService(),
          crashReportService: const NoOpCrashReportService(),
          child: const MaterialApp(home: CustomPromptsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.getCustomPromptsCallCount, 1);

      // Second pump with notifyDependents: true forces updateShouldNotify to
      // return true, causing Flutter to call didChangeDependencies on all
      // AppServices subscribers. The _initialized guard must block the second
      // _loadPrompts call.
      await tester.pumpWidget(
        AppServices(
          promptRepository: repo,
          drillSettingsRepository: InMemoryDrillSettingsRepository(),
          practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
          journalRepository: InMemoryJournalRepository(),
          appPreferencesRepository: InMemoryAppPreferencesRepository(),
          ttsService: FakeTtsService(),
          crashReportService: const NoOpCrashReportService(),
          notifyDependents: true,
          child: const MaterialApp(home: CustomPromptsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Guard must have blocked the second _loadPrompts call.
      expect(repo.getCustomPromptsCallCount, 1);
    });
  });
}
