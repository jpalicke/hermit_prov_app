# Hermit Prov

A free, offline-first Flutter app for solo long-form comedy improv practice.

---

## What it does

Hermit Prov is a practice tool for comedic long-form improvisers who train alone. It provides:

- **Cat & Clock** — timed speaking/regroup cycles with random prompts
- **Two-Character Scenes** — scene + regroup timer with random prompts
- **A-to-C / Bad Idea / Initiation** — rapid-fire prompt intervals
- **Character Creation** — timed first-pass and return-pass cycle for building characters
- **Five Line Scenes** — manual or auto-advance prompt-per-line practice
- **Suggestion Generator** — standalone random prompt tool
- **Emotion Wheel** — visual reference for Plutchik's emotion wheel
- **Countdown Timer** — generic countdown with pause/resume
- **Journal** — text notes attached to drills or standalone
- **Practice History** — session log with stats and streaks
- **Custom Suggestion Bank** — add your own words and phrases to the prompt pool
- **Data Backup / Restore** — export and import all your content as a JSON file

All data stays on your device. The app works fully offline after installation.

---

## Tech stack

- Flutter 3.41.x / Dart 3.11.x / Material 3
- Drift (SQLite) for structured data
- SharedPreferences for app settings
- No routing package — imperative Navigator
- No state management package — InheritedWidget + StatefulWidget

---

## Getting started

```bash
flutter pub get
flutter test
flutter run
```

For a connected device or emulator:

```bash
flutter run -d <device-id>
```

---

## Documentation

See the [`docs/`](docs/) directory for the full knowledge-transfer suite:

| Document | What it covers |
|----------|---------------|
| [KT_00_PROJECT_OVERVIEW.md](docs/KT_00_PROJECT_OVERVIEW.md) | Product goals, constraints, feature list |
| [KT_01_DEV_SETUP.md](docs/KT_01_DEV_SETUP.md) | Environment setup, build, test, analyze |
| [KT_02_ARCHITECTURE.md](docs/KT_02_ARCHITECTURE.md) | Layer structure, DI, repository pattern, navigation |
| [KT_03_DRILL_SYSTEM.md](docs/KT_03_DRILL_SYSTEM.md) | Drill state machine deep dive |
| [KT_04_DATA_LAYER.md](docs/KT_04_DATA_LAYER.md) | Domain models, repositories, SQLite schema, backup |
| [KT_05_TESTING_GUIDE.md](docs/KT_05_TESTING_GUIDE.md) | Test types, structure, how to write new tests |
| [KT_06_OPEN_ISSUES.md](docs/KT_06_OPEN_ISSUES.md) | Known gaps and open GitHub issues |

Also see [`DEVELOPER_NOTES.md`](DEVELOPER_NOTES.md) for implementation decisions and platform notes.
