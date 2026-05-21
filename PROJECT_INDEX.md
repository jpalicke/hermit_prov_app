# Project Index: hermit_prov_app

Generated: 2026-05-21

## Overview

**Hermit Prov** — free, offline-first Flutter app for solo long-form comedy improv practice.
No accounts, no cloud, no AI, no ads. All data stays local.

- Package: `com.hermitprov.hermit_prov_app`
- Flutter: 3.41.x / Dart: 3.11.x / Material 3
- Platform targets: Android, iOS, Web (tools-only build)

---

## Entry Points

| File | Purpose |
|---|---|
| `lib/main.dart` | Mobile entry point — runZonedGuarded + crash handler |
| `lib/main_web.dart` | Web entry point — tools-only, no crash reporting |
| `lib/app.dart` | Root MaterialApp with theme notifier |
| `lib/ui/navigation/bottom_nav_shell.dart` | 3-tab shell: Practice / History / Settings |

---

## Architecture

```
lib/
  core/
    di/app_services.dart          — InheritedWidget DI root; .withSQLite() / .withInMemory()
                                    Field: notifyDependents (bool, default false) — test hook
                                    to force updateShouldNotify=true in widget tests
    theme/app_theme.dart          — lightTheme / darkTheme ThemeData
  domain/                         — pure Dart, no Flutter deps
    drills/
      drill_id.dart               — DrillId enum (atoc, catClock, characterCreation, fiveLine, twoCharacter)
      drill_segment.dart          — DrillSegment value object
      drill_session_controller.dart — DrillSessionController state machine
      drill_session_state.dart    — DrillSessionState sealed class
      drill_settings.dart         — per-drill config value objects
      drill_settings_repository.dart — abstract repo
      atoc/atoc_sequence.dart     — A-to-C drill segment generator
      cat_clock/cat_clock_sequence.dart
      character_creation/character_creation_cycle.dart
      two_character/two_character_sequence.dart
    prompts/
      prompt_category.dart        — PromptCategory enum + word buckets
      prompt_picker.dart          — PromptPicker (weighted random selection)
      prompt_repository.dart      — abstract CRUD repo
      custom_prompt.dart          — CustomPrompt value object
      custom_prompt_validator.dart
      built_in_prompt.dart
    history/
      practice_session.dart       — PracticeSession value object
      practice_history_repository.dart
      practice_stats.dart         — PracticeStats aggregation
    journal/
      journal_entry.dart
      journal_repository.dart
    settings/
      app_preferences.dart        — AppPreferences (theme, TTS rate)
      app_preferences_repository.dart
      app_theme_preference.dart   — AppThemePreference enum
    backup/app_backup.dart        — AppBackup / MergeResult value objects
    crash/
      crash_report.dart
      crash_report_service.dart
      crash_payload_sanitizer.dart
    emotions/emotion_wheel_data.dart — kEmotionWheel dataset + EmotionEntry
    tts/
      tts_service.dart            — abstract TTS interface
      hands_free_announcement_policy.dart
  data/
    local/
      app_database.dart           — Drift SQLite schema (tables: prompts, journal, history, drillSettings)
      app_database.g.dart         — generated
      database_opener.dart        — platform-aware DB opener
    repositories/
      drift_*.dart                — SQLite-backed repo implementations
      in_memory_*.dart            — in-memory repos (web build / tests)
      shared_preferences_app_preferences_repository.dart
    backup/
      backup_service.dart         — abstract BackupService
      local_backup_service.dart   — JSON export/import via Share / FilePicker
    crash/no_op_crash_report_service.dart
    seed/
      seed_prompts.dart           — seeds all built-in prompts on first launch
      categories/                 — word lists: activities, emotions, events, genre,
                                    locations, objects, occupations, relationships
    tts/
      flutter_tts_service.dart    — FlutterTts wrapper
      fake_tts_service.dart       — no-op for tests
  features/
    practice/
      practice_screen.dart        — drill card grid, drill picker
      drill_configure_screen.dart — per-drill settings UI
      drill_session_shell.dart    — active session chrome (timer, back-gesture intercept)
    drills/
      atoc/                       — A-to-C configure + session screens
      cat_clock/                  — Cat Clock configure + session screens
      character_creation/         — Character Creation configure + session screens
      five_line/                  — Five Line configure + session screens
      two_character/              — Two Character configure + session screens
    history/history_screen.dart   — session log + stats
    journal/
      journal_screen.dart
      journal_entry_screen.dart
    prompts/
      custom_prompts_screen.dart  — CRUD list of user-added prompts
      add_edit_custom_prompt_screen.dart
    settings/
      settings_screen.dart        — theme, TTS, drill defaults, backup, reset
      tts_settings_screen.dart
      privacy_about_screen.dart
    tools/
      tools_screen.dart           — 5-tile tools launcher
      prompt_generator_screen.dart
      timer_screen.dart
      emotion_wheel_screen.dart
    crash/crash_report_dialog.dart
  web/web_app.dart                — HermitProvWebApp — in-memory + ToolsScreen only
```

---

## Key Abstractions

| Interface | SQLite impl | In-memory impl |
|---|---|---|
| `PromptRepository` | `DriftPromptRepository` | `InMemoryPromptRepository` |
| `JournalRepository` | `DriftJournalRepository` | `InMemoryJournalRepository` |
| `PracticeHistoryRepository` | `DriftPracticeHistoryRepository` | `InMemoryPracticeHistoryRepository` |
| `DrillSettingsRepository` | `DriftDrillSettingsRepository` | `InMemoryDrillSettingsRepository` |
| `AppPreferencesRepository` | `SharedPreferencesAppPreferencesRepository` | `InMemoryAppPreferencesRepository` |
| `TtsService` | `FlutterTtsService` | `FakeTtsService` |
| `CrashReportService` | *(none — no-op only)* | `NoOpCrashReportService` |

---

## Drill Inventory

| Drill | ID | Configure screen | Session screen |
|---|---|---|---|
| A-to-C | `atoc` | `AtoCConfigureScreen` | `AtoCSessionScreen` |
| Cat Clock | `catClock` | `CatClockConfigureScreen` | `CatClockSessionScreen` |
| Character Creation | `characterCreation` | `CharacterCreationConfigureScreen` | `CharacterCreationSessionScreen` |
| Five Line | `fiveLine` | `FiveLineConfigureScreen` | `FiveLineSessionScreen` |
| Two Character | `twoCharacter` | `TwoCharacterConfigureScreen` | `TwoCharacterSessionScreen` |

---

## Test Coverage

**47 test files — all passing**

```
test/unit/
  domain/   — drill sequences, session controller, prompt picker,
              custom prompt validator, drill settings defaults, word bucket
  history/  — practice stats, session logging
  journal/  — journal entry
  tts/      — hands-free policy, fake TTS
  crash/    — crash payload sanitizer
  backup_service_test.dart

test/repository/
  prompt_repository_test.dart
  drift_prompt_repository_test.dart
  drill_settings_repository_test.dart
  drift_drill_settings_repository_test.dart

test/widget/
  app_shell_test.dart
  di_wiring_test.dart
  accessibility_smoke_test.dart
  acceptance/v1_acceptance_test.dart
  drills/  — atoc, cat_clock, character_creation, five_line, two_character
  drill_shell/drill_shell_test.dart
  practice/ — drill_session_shell_back_gesture_test
  practice_home_test.dart
  history/history_screen_test.dart
  journal/journal_screen_test.dart
  prompts/custom_prompts_screen_test.dart
  settings/ — settings_screen, privacy_about, tts
  tools/    — tools_screen, prompt_generator, timer, emotion_wheel
  web/web_app_test.dart
  crash/    — crash_report_dialog, crash_handler

integration_test/app_test.dart
```

---

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `drift` | ^2.33.0 | SQLite ORM — all persistent storage |
| `drift_flutter` | ^0.3.0 | Platform DB opener for Flutter |
| `shared_preferences` | ^2.5.5 | AppPreferences persistence |
| `flutter_tts` | ^4.2.0 | Text-to-speech for hands-free mode |
| `file_picker` | ^8.1.7 | Backup import (JSON file selection) |
| `share_plus` | ^10.1.4 | Backup export |
| `url_launcher` | ^6.3.0 | External links in Privacy/About |
| `font_awesome_flutter` | ^11.0.0 | Icons |
| `very_good_analysis` | ^7.0.0 | Lint rules (dev) |

---

## Build Commands

```bash
# Run all tests
flutter test

# Static analysis
flutter analyze

# Mobile build
flutter build apk --release
flutter build ios --release

# Web build (tools-only)
flutter build web --target lib/main_web.dart

# Regenerate Drift code
dart run build_runner build --delete-conflicting-outputs
```

---

## Open PRs (as of 2026-05-21)

- **#37** `fix/issue-33-load-prompts-guard` — guard _loadPrompts against double-fire; test uses _NotifyingAppServices to reliably trigger didChangeDependencies
- **#36** `fix/issue-31-32-prompt-generator-category-invariants` — prompt generator no-op semantics on last chip; dead guards removed
- **#35** `fix/issue-34-storefile-absolute-path` — validate storeFile is absolute path in Gradle; import ordering fixed
- **#30** `feature/ios-ci-workflow` — iOS CI (needs rebase before merge)

## Open Issues (as of 2026-05-21)

- **#39** `custom_prompts_screen`: no error state when _loadPrompts throws after initialization
- **#34** Document key.properties storeFile must be an absolute path (addressed by PR #35)
- **#33** custom_prompts_screen: _loadPrompts fires on every didChangeDependencies (addressed by PR #37)
- **#32** prompt_generator_screen: isolate-on-tap behavior (addressed by PR #36)
- **#31** prompt_generator_screen: auto-advance timer with empty categories (addressed by PR #36)
- **#29** Add iOS signing secrets to GitHub repository (manual)
- **#28** Set up Apple Developer portal for iOS release signing (manual)
- **#5** Decide: tablet/iPad layout for v1 (design decision pending)
