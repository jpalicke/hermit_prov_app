# Hermit Prov — Testing Guide

## Philosophy

The project follows TDD. Tests are written before or alongside production code. The rule: **do not commit code unless tests pass and `flutter analyze` is clean.**

Tests serve as executable documentation. Before you change anything, read the tests for it — they describe the intended behavior better than the code often does.

---

## Running Tests

```bash
flutter test                          # run everything (391 tests)
flutter test test/unit/               # unit tests only
flutter test test/repository/         # repository integration tests only
flutter test test/widget/             # widget tests only
flutter test test/widget/drills/      # all drill widget tests
flutter test path/to/specific_test.dart  # one file
```

All tests must pass. Zero failures. The test output must be clean.

---

## Test Directory Structure

```
test/
├── unit/                          # Pure-Dart unit tests (no Flutter runtime)
│   ├── domain/
│   │   ├── atoc_sequence_test.dart
│   │   ├── cat_clock_sequence_test.dart
│   │   ├── character_creation_cycle_test.dart
│   │   ├── two_character_sequence_test.dart
│   │   ├── drill_session_controller_test.dart
│   │   ├── drill_settings_defaults_test.dart
│   │   ├── prompt_picker_test.dart
│   │   ├── custom_prompt_validator_test.dart
│   │   └── word_bucket_test.dart
│   ├── history/
│   │   ├── practice_stats_test.dart
│   │   └── session_logging_threshold_test.dart
│   ├── journal/
│   │   └── journal_entry_test.dart
│   ├── tts/
│   │   ├── fake_tts_service_test.dart
│   │   └── hands_free_announcement_policy_test.dart
│   ├── crash/
│   │   └── crash_payload_sanitizer_test.dart
│   └── backup_service_test.dart
│
├── repository/                    # Drift SQLite integration tests
│   ├── drift_prompt_repository_test.dart
│   ├── drift_drill_settings_repository_test.dart
│   ├── drift_practice_history_repository_test.dart
│   └── drift_journal_repository_test.dart
│
└── widget/                        # Flutter widget tests
    ├── widget_test.dart            # Top-level smoke test
    ├── app_shell_test.dart         # Bottom nav, initial tab
    ├── di_wiring_test.dart         # AppServices DI is complete
    ├── accessibility_smoke_test.dart
    ├── acceptance/
    │   └── v1_acceptance_test.dart # End-to-end v1 acceptance scenarios
    ├── drill_shell/
    │   └── drill_session_shell_test.dart
    ├── drills/
    │   ├── atoc/
    │   ├── cat_clock/
    │   ├── character_creation/
    │   ├── five_line/
    │   └── two_character/
    ├── history/
    ├── journal/
    ├── prompts/
    ├── settings/
    ├── tools/
    ├── tts/
    └── crash/
```

---

## Three Test Types

### 1. Unit Tests (`test/unit/`)

Pure Dart. No Flutter. No widgets. No `pumpWidget`. These test business logic in isolation.

Example: testing `DrillSessionController`

```dart
test('tick advances segment elapsed', () {
  final controller = DrillSessionController(segments: [
    DrillSegment(id: '1', type: DrillSegmentType.speaking, duration: const Duration(seconds: 60)),
  ]);
  controller.start();
  controller.tick();
  expect(controller.state.segmentElapsed, const Duration(seconds: 1));
});
```

Unit tests are fast. Run them constantly. When you change a domain class, run its unit tests immediately.

**Key unit test files:**

| File | What it tests |
|------|--------------|
| `drill_session_controller_test.dart` | State machine: all transitions, tick behavior, loops, finite completion |
| `practice_stats_test.dart` | Streak calculation, per-drill aggregation |
| `hands_free_announcement_policy_test.dart` | When TTS fires; countdown rules; 30s segment threshold |
| `prompt_picker_test.dart` | Category filtering, randomness, custom+built-in mixing |
| `custom_prompt_validator_test.dart` | Blocklist rules; valid text passes; slur/explicit text fails |
| `backup_service_test.dart` | Build, export, import, merge logic |

### 2. Repository Integration Tests (`test/repository/`)

These test the Drift repositories against a real in-memory SQLite database (`NativeDatabase.memory()`). They exercise the actual SQL, not a mock.

```dart
setUp(() async {
  db = AppDatabase(NativeDatabase.memory());
  repo = DriftPromptRepository(db, buildSeedPrompts());
});

tearDown(() async {
  await db.close();
});

test('adding a custom prompt persists it', () async {
  final prompt = CustomPrompt(id: 'test-1', text: 'a chair', ...);
  await repo.addCustomPrompt(prompt);
  final results = await repo.getCustomPrompts();
  expect(results, contains(prompt));
});
```

**Never mock the database.** These tests use a real SQLite instance so SQL logic is actually exercised.

### 3. Widget Tests (`test/widget/`)

These test Flutter widgets. They use `AppServices.withInMemory()` for all dependency injection — no real disk I/O during tests.

```dart
testWidgets('shows prompt text during speaking segment', (tester) async {
  await tester.pumpWidget(
    AppServices.withInMemory(
      child: const MaterialApp(home: CatClockSessionScreen(...)),
    ),
  );
  await tester.tap(find.text('Start'));
  await tester.pump();
  expect(find.textContaining('→'), findsOneWidget);
});
```

**Standard widget test setup pattern:**

```dart
Widget buildTestWidget({required Widget child}) {
  return AppServices.withInMemory(child: MaterialApp(home: child));
}
```

Use this wrapper in every widget test. It puts `AppServices` in the tree so `AppServices.of(context)` works anywhere inside.

---

## What to Test

When you add a feature, tests must cover:

| Layer | Test type | What |
|-------|-----------|------|
| Domain logic (sequence builders, state machines, validators) | Unit | All cases: normal, edge, error |
| Repository (Drift) | Repository integration | CRUD, edge cases, ordering |
| Widget screens | Widget | Core happy path, empty state, error state |
| New drill | All three | Sequence builder unit test + session screen widget test |

---

## Testing the Drill State Machine

The `DrillSessionController` is the most complex domain object. Its tests live in `drill_session_controller_test.dart`. Cover these scenarios:

- `start()` transitions from idle to running
- `pause()` / `resume()` toggle
- `tick()` advances elapsed time and triggers segment transitions
- Loop boundary: loops count increments, `currentSegmentIndex` resets
- Finite completion: `status` becomes `completed` after last segment
- `stop()` sets status to `stopped` (terminal)
- `reset()` restores to full initial state regardless of current status
- `tick()` is a no-op when paused or stopped

---

## Testing Widget Drill Sessions

Drill session widget tests need to simulate time passing. Use `tester.pump(Duration)` to advance the clock and trigger ticks.

Example pattern (from atoc session test):

```dart
testWidgets('shows new prompt after interval', (tester) async {
  await tester.pumpWidget(buildTestWidget(child: atocScreen));
  await tester.tap(find.text('Start'));
  await tester.pump();

  // Pump past the full interval to trigger a loop
  await tester.pump(const Duration(seconds: 31));
  await tester.pump(); // settle

  // New prompt should have been fetched
  expect(find.byType(Text), findsWidgets);
});
```

**Important:** Widget tests do not exercise real `Timer.periodic` calls. `DrillSessionShell` creates a timer, but `pumpWidget` + `pump(duration)` advances Flutter's fake async clock.

---

## Accessibility Tests

`test/widget/accessibility_smoke_test.dart` runs `SemanticsHandle` checks across key screens. When adding new screens, add a corresponding semantic check for:

- All interactive elements have semantic labels
- Section headers are marked as headers
- Buttons have meaningful action labels (not just icon descriptions)

---

## The Acceptance Test

`test/widget/acceptance/v1_acceptance_test.dart` is a high-level smoke test covering the full feature set visible at v1:

- Bottom nav has correct tabs
- All 5 drills appear on the practice screen
- Tools card appears
- Settings screen has all sections
- All tool tiles appear on the tools screen

These tests are intentionally broad — they exist to catch regressions when refactoring structure. They're not a substitute for feature-level tests.

---

## Continuous Discipline

Before any commit:

```bash
flutter test      # must pass
flutter analyze   # must be clean
```

If tests fail and you don't understand why: stop, read the failure carefully, trace the actual error. Do not comment out tests. Do not skip failing tests. Fix the root cause.
