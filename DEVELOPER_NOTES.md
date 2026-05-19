# Hermit-Prov Developer Notes

## Architecture Overview

The app is split into four layers:

- **domain** — pure Dart interfaces and value objects. No Flutter, no storage. Defines repository contracts (`PracticeHistoryRepository`, `JournalRepository`, `PromptRepository`, `DrillSettingsRepository`, `AppPreferencesRepository`), drill session logic (`DrillSessionController`, `DrillSessionState`), and domain models (`PracticeSession`, `JournalEntry`, `CustomPrompt`, `DrillSettings`, etc.).

- **data** — concrete implementations of domain interfaces. Two flavours for every repository: `Drift*` (on-device SQLite via Drift ORM, used in production) and `InMemory*` (lightweight in-memory maps, used in tests). `FakeTtsService` is the in-memory TTS implementation used in tests.

- **features** — Flutter screens and widgets, grouped by functional area: `practice/`, `drills/`, `history/`, `journal/`, `settings/`, `tools/`, `prompts/`, `crash/`. Each drill has its own sub-folder with a configure screen and a session screen.

- **core** — app-wide utilities: `theme/` (Material 3 color scheme and typography), `di/` (`AppServices` InheritedWidget that wires all repositories into the widget tree).

Navigation is handled imperatively via `Navigator.push`. `BottomNavShell` wraps the three root tabs (Practice, History, Settings) in an `IndexedStack` so tab state is preserved.

## Local Data Schema

### Drift tables (SQLite, file `app_database.dart`)

| Table | Key columns | Purpose |
|---|---|---|
| `CustomPrompts` | `id` (PK), `promptText`, `category`, `createdAtMs`, `updatedAtMs` | User-created prompts; `category` stores `PromptCategory.name` |
| `DrillSettingsTable` | `drillId` (PK), `settingsJson` | Per-drill settings stored as a JSON blob keyed by `DrillId.name` |
| `PracticeSessions` | `id` (PK), `drillId`, `startedAtMs`, `durationSeconds`, `loggedAtMs` | Practice history; sessions under 30 s are never written |
| `JournalEntries` | `id` (PK), `createdAtMs`, `updatedAtMs`, `drillTag` (nullable), `body` | Journal entries with optional drill association |

### SharedPreferences keys (file `shared_preferences_app_preferences_repository.dart`)

| Key | Type | Purpose |
|---|---|---|
| `app_theme_preference` | String | `AppThemePreference.name` (system / light / dark) |
| `tts_voice` | String (nullable) | Selected TTS voice identifier |
| `tts_speaking_rate` | Double | TTS speaking rate (0.0–1.0) |

## Export/Import Schema Versioning

Backup files are JSON with a top-level `schemaVersion` field. The current version is **1**.

Schema v1 fields:
```
schemaVersion: 1
exportedAt: ISO-8601 UTC string
customPrompts: [ { id, promptText, category, createdAtMs, updatedAtMs }, ... ]
journalEntries: [ { id, body, drillTag?, createdAtMs, updatedAtMs }, ... ]
drillSettings: { drillId: { ...settingsJson } }
preferences: { themePreference, ttsVoice?, ttsSpeakingRate }
```

Note: practice history is intentionally excluded from backups. History is considered device-local telemetry; users carry their creative work (prompts, journal) across devices, not their statistics.

**Bumping to version 2:** Add a migration branch in `LocalBackupService.importFromJson`. Check `json['schemaVersion']` before calling `AppBackup.fromJson`. For each new or renamed field, apply a default or transform in the migration branch before passing the normalized map to `AppBackup.fromJson`.

## Prompt System

Prompts come from two sources that are merged at query time:

1. **Built-in prompts** (`BuiltInPrompt`) — shipped with the app, defined in `lib/data/seed/seed_prompts.dart` and per-category files under `lib/data/seed/categories/`. These are never stored in the database; they live in memory only and are injected into `DriftPromptRepository` at construction via `buildSeedPrompts()`.

2. **Custom prompts** (`CustomPrompt`) — user-created, stored in the `CustomPrompts` Drift table.

`PromptPicker` draws from both sources when generating a random prompt for a given set of `PromptCategory` values.

**To replace placeholder prompts with final human-curated lists:** Edit the category seed files in `lib/data/seed/categories/` (e.g. `seed_locations.dart`). Each file exports a `List<BuiltInPrompt>`. No migrations or database changes are needed since built-ins live entirely in memory.

**Prompt validation rules** (enforced by `CustomPromptValidator`):
- Body must be non-empty after trimming.
- Maximum 200 characters.
- No leading or trailing whitespace (the validator strips it before checking length).

## Crash Reporting

`CrashReportService` is an interface in `lib/domain/crash/`. The only concrete implementation shipped is `NoOpCrashReportService`, which silently discards all reports.

When a fatal exception is caught, `CrashReportDialog` is shown to the user, who can choose to send a report. The report is scrubbed through `CrashPayloadSanitizer` before being surfaced — custom prompts and journal text are never included.

**To wire a real crash provider:** Implement `CrashReportService` (e.g. using Sentry, Firebase Crashlytics, or a custom HTTP endpoint). Register the implementation in `AppServices.withLocalStorage()` by replacing `NoOpCrashReportService()` with your implementation. The interface receives a `CrashReport` with sanitized technical fields only.

## Offline Operation

The app makes zero network requests after installation. All persistent data is stored locally:

- Structured data (prompts, history, journal, drill settings) via Drift (SQLite, `app_database.dart`).
- Preferences (theme, TTS voice) via SharedPreferences.

The two packages that interact with external systems do so only when the user explicitly triggers an action:

- `url_launcher` — opens links in the browser or mail client (Privacy and About screen). No background requests.
- `share_plus` — hands off a file to the OS share sheet (Data Backup export). The app itself does not transmit the file.

## Running Locally

```bash
flutter pub get
flutter test
flutter run
```

For a connected device or simulator:
```bash
flutter run -d <device-id>
```

To run only a subset of tests:
```bash
flutter test test/widget/acceptance/
flutter test test/unit/
flutter test test/repository/
```

## Manual QA Checklist

Items that cannot be driven by automated widget tests:

- [ ] **Export backup:** tap Settings > Export Data, verify the file is shared to Files, email, or another app successfully.
- [ ] **Import backup:** export first, uninstall, reinstall, tap Import Data, select the file — verify all custom prompts, journal entries, and preferences are restored.
- [ ] **TTS voices:** open Settings > Text-to-Speech, verify available system voices are listed, select a voice, run a drill in hands-free mode and confirm the correct voice speaks.
- [ ] **Portrait lock:** rotate the device to landscape — verify the app stays in portrait orientation on both iOS and Android.
- [ ] **Tablet layout:** run on an iPad or large Android tablet — verify the Settings list is constrained in width, the Emotion Wheel fills a square, and nothing is stretched or clipped.
- [ ] **Dark mode:** switch to Dark in Settings > Appearance, navigate all screens and verify legibility throughout.
- [ ] **Offline:** disable Wi-Fi and cellular data, then open the app fresh (force-quit and relaunch) — verify all features (drills, prompt generator, journal, history, timer, emotion wheel) work without a network connection.
