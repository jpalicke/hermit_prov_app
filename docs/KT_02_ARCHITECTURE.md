# Hermit Prov — Architecture Guide

## Layer Overview

The codebase follows a classic layered architecture with strict dependency direction:

```
features/ (UI)
    ↓ uses
domain/ (interfaces + pure business logic)
    ↓ implemented by
data/ (repositories, persistence, TTS)
    ↓ injected via
core/di/ (AppServices — the DI root)
```

`domain/` has zero Flutter imports. Everything in it is plain Dart. This is intentional: business rules can be tested without a Flutter runtime, and they don't care whether data comes from SQLite, memory, or a network call.

---

## Directory Map

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + theme listener
│
├── core/
│   ├── di/app_services.dart           # InheritedWidget DI container
│   └── theme/app_theme.dart           # lightTheme / darkTheme
│
├── domain/
│   ├── drills/                        # Drill state machine + settings models
│   ├── prompts/                       # Prompt models, picker, validator
│   ├── history/                       # Session model, stats computation
│   ├── journal/                       # Journal entry model
│   ├── settings/                      # AppPreferences model + theme enum
│   ├── tts/                           # TTS service interface + announcement policy
│   ├── crash/                         # Crash report model + service interface
│   ├── backup/                        # AppBackup model
│   └── emotions/                      # Emotion wheel data (compile-time const)
│
├── data/
│   ├── local/                         # Drift database definition + generated code
│   ├── repositories/                  # Repository implementations (Drift + in-memory)
│   ├── seed/                          # Built-in prompt lists (8 categories)
│   ├── tts/                           # FlutterTtsService + FakeTtsService
│   ├── backup/                        # LocalBackupService
│   └── crash/                         # NoOpCrashReportService
│
├── features/
│   ├── practice/                      # Practice home + DrillSessionShell + DrillConfigureScreen
│   ├── drills/                        # Per-drill configure + session screens
│   │   ├── cat_clock/
│   │   ├── character_creation/
│   │   ├── two_character/
│   │   ├── atoc/
│   │   └── five_line/
│   ├── history/                       # History screen
│   ├── journal/                       # Journal list + entry screens
│   ├── prompts/                       # Custom prompts list + add/edit screens
│   ├── settings/                      # Settings, TTS settings, Privacy/About
│   ├── tools/                         # Tools home + Suggestion Generator + Timer + Emotion Wheel
│   └── crash/                         # Crash report dialog
│
└── ui/
    └── navigation/bottom_nav_shell.dart  # 3-tab shell
```

---

## Dependency Injection: `AppServices`

`AppServices` is an `InheritedWidget` placed at the root of the widget tree (inside `main()`, above `HermitProvApp`).

Any widget anywhere calls `AppServices.of(context)` to get any dependency.

```dart
// Getting a repository from any widget
final repo = AppServices.of(context).journalRepository;
```

**What AppServices exposes:**

| Property | Type | Purpose |
|----------|------|---------|
| `promptRepository` | `PromptRepository` | Built-in + custom prompts |
| `drillSettingsRepository` | `DrillSettingsRepository` | Per-drill settings persistence |
| `practiceHistoryRepository` | `PracticeHistoryRepository` | Session log |
| `journalRepository` | `JournalRepository` | Journal entries |
| `appPreferencesRepository` | `AppPreferencesRepository` | Theme + TTS rate |
| `ttsService` | `TtsService` | Text-to-speech |
| `themeNotifier` | `ValueNotifier<ThemeMode>` | Live theme switching |

**Two factory methods:**

| Factory | When used | Storage |
|---------|-----------|---------|
| `AppServices.withLocalStorage()` | Production (called in `main.dart`) | SQLite + SharedPreferences |
| `AppServices.withInMemory()` | Widget tests | RAM only (lost on restart) |

`updateShouldNotify` returns `false` — repositories never swap after construction, so no tree-wide rebuild ever triggers from DI.

---

## The Domain Layer

### What belongs in `domain/`

- Data models (immutable value objects)
- Repository interfaces (abstract classes)
- Pure business logic (no I/O, no Flutter)
- Enums

### What does NOT belong in `domain/`

- `import 'package:flutter/...'` — any Flutter import means you're in the wrong layer
- Any I/O: disk, network, SharedPreferences, SQLite
- Widget code

---

## Repository Pattern

Every data concern has three parts:

1. **Interface** in `domain/` — abstract class with method signatures only
2. **Drift/SharedPreferences implementation** in `data/repositories/` — the production version
3. **In-memory implementation** in `data/repositories/` — for tests; data lives in a List/Map in RAM

Example for prompts:

```
domain/prompts/prompt_repository.dart         # abstract class PromptRepository
data/repositories/drift_prompt_repository.dart # DriftPromptRepository implements PromptRepository
data/repositories/in_memory_prompt_repository.dart # InMemoryPromptRepository implements PromptRepository
```

Widget tests use `AppServices.withInMemory()` which wires all in-memory versions. Production uses `AppServices.withLocalStorage()` which wires all Drift/SharedPreferences versions.

---

## Persistence: Two Technologies

| What | Technology | Why |
|------|-----------|-----|
| Custom prompts, journal entries, drill settings, practice history | **Drift (SQLite)** | Structured data with querying needs |
| App preferences (theme, TTS rate) | **SharedPreferences** | Two simple scalar values |

The SQLite file lives in the app's documents directory on the device. Drift handles all schema creation and migrations. The database has 4 tables:

| Table | Content |
|-------|---------|
| `CustomPrompts` | User-added suggestion words |
| `DrillSettingsTable` | Per-drill JSON blobs (keyed by DrillId name) |
| `PracticeSessions` | Append-only session log |
| `JournalEntries` | Freeform notes |

Built-in prompts are NOT stored in SQLite. They live as Dart constants in `lib/data/seed/categories/` and are loaded into memory at app startup.

---

## Navigation

No routing package. All navigation is direct `Navigator.push` / `MaterialPageRoute`. The bottom nav shell uses `IndexedStack` for tab persistence (all 3 tabs stay mounted simultaneously).

```dart
// Typical navigation push
Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (_) => const SomeScreen()),
);
```

The History tab is the one exception to the normal `IndexedStack` behavior: it uses a `ValueKey(_historyVersion)` that increments every time the user taps the History tab. This forces the widget to fully recreate (and re-fetch data) on each visit. See `KT_03_DRILL_SYSTEM.md` for more on why.

---

## Theme System

`AppTheme.lightTheme` and `AppTheme.darkTheme` are defined in `lib/core/theme/app_theme.dart` using Material 3 color schemes.

`AppServices.themeNotifier` is a `ValueNotifier<ThemeMode>`. `app.dart` listens to it. Changing the notifier value triggers a live theme switch with no app restart.

```dart
// Switch to dark mode from anywhere
AppServices.of(context).themeNotifier.value = ThemeMode.dark;
```

---

## TTS (Text-to-Speech)

The TTS service interface lives in `domain/tts/tts_service.dart`. Production uses `FlutterTtsService` (backed by `flutter_tts`). Tests use `FakeTtsService` (no-op, silent).

`HandsFreeAnnouncementPolicy` is a pure-Dart class that decides WHAT to announce at each tick: drill name + prompt at segment start, countdown alerts at 30 s / 10 s / final 5-4-3-2-1. The policy's rules are fully unit-tested.

---

## Sealed Classes

`DrillSettings` is a `sealed class`. The five subclasses correspond to the five drills:

```dart
sealed class DrillSettings { ... }
class CatClockSettings extends DrillSettings { ... }
class TwoCharacterScenesSettings extends DrillSettings { ... }
// etc.
```

Any `switch` on a `DrillSettings` instance must be exhaustive. The Dart compiler will error if you add a new drill's settings class and forget to handle it in existing switches. This is intentional — it ensures no case is silently missed.

The same pattern applies to `DrillId` (an enum with 5 values): any `switch` on `DrillId` must cover all 5 cases.

---

## Immutability

All domain models are immutable. They use `copyWith` for modification:

```dart
final updated = AppPreferences(
  themePreference: AppThemePreference.dark,
  ttsSpeakingRate: current.ttsSpeakingRate,
);
```

`DrillSessionState` and `DrillSessionController` follow the same pattern — the state object is always a fresh snapshot; the controller holds and replaces it.

---

## The 30-Second Logging Rule

`DrillSessionShell._maybeLogSession()` only writes a session to `PracticeHistoryRepository` when `sessionElapsed >= 30 seconds`. This prevents accidental taps from polluting the practice history. The 30-second threshold is tested explicitly in `test/unit/history/session_logging_threshold_test.dart`.

---

## Crash Reporting (Not Wired Up)

The domain, data, and feature layers for crash reporting all exist:
- `lib/domain/crash/` — interface + sanitizer
- `lib/data/crash/no_op_crash_report_service.dart` — no-op implementation
- `lib/features/crash/crash_report_dialog.dart` — the dialog widget

However, `CrashReportService` is not in `AppServices`, and `main.dart` has no `FlutterError.onError` or `runZonedGuarded`. The crash dialog will never fire. See GitHub issue #1.
