# Hermit Prov — Developer Setup Guide

## Prerequisites

| Tool | Required Version | Notes |
|------|-----------------|-------|
| Flutter | 3.41.x | Use `flutter upgrade` to match |
| Dart | 3.11.x | Comes with Flutter |
| Android Studio | Any recent | For Android emulator; install via Flutter docs |
| Xcode | 14+ | macOS only; required for iOS builds |
| Java | 17+ | Required for Android Gradle builds |

Check your setup: `flutter doctor -v`

---

## Clone and Install

```bash
git clone https://github.com/jpalicke/hermit_prov_app.git
cd hermit_prov_app
flutter pub get
```

---

## Code Generation (Drift ORM)

The Drift database layer uses generated code. The generated file `lib/data/local/app_database.g.dart` is checked into the repo, so you don't need to run this normally. But if you change `lib/data/local/app_database.dart` (add a table, column, etc.), you must regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Do not manually edit `*.g.dart` files.

---

## Running the App

### On a connected Android device or emulator:
```bash
flutter run
```

### On a specific device:
```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

### On iOS (macOS only):
```bash
flutter run -d ios
```

---

## Running Tests

All tests — unit, repository, and widget — run with a single command:

```bash
flutter test
```

Expected output: **391 tests, 0 failures** (as of v1.0.1). If you see failures, do not proceed; fix them first.

To run a specific file:
```bash
flutter test test/unit/domain/drill_session_controller_test.dart
```

To run a specific directory:
```bash
flutter test test/widget/drills/
```

---

## Static Analysis

```bash
flutter analyze
```

Must be **clean (0 issues)** before committing. Fix any warnings — the codebase ships with zero analysis warnings.

---

## Building for Release

### Android APK:
```bash
flutter build apk --release
```

> **Note:** CI release builds are signed automatically via the `android-release.yml` workflow using secrets stored in GitHub. For local release builds you need `android/key.properties` pointing at a valid keystore — see `docs/KT_06_OPEN_ISSUES.md` issue #2.

### iOS Archive (macOS only):
```bash
flutter build ios --release
```

Requires an Apple Developer account and signing configuration in Xcode.

---

## Project Structure at a Glance

```
hermit_prov_app/
├── lib/                    # All production Dart code
│   ├── main.dart           # Entry point
│   ├── app.dart            # MaterialApp root
│   ├── core/               # Theme, DI container
│   ├── domain/             # Business logic (no Flutter deps)
│   ├── data/               # Repository implementations, seed data
│   ├── features/           # UI screens organized by feature
│   └── ui/                 # Navigation shell
├── test/                   # All tests
│   ├── unit/               # Pure-Dart unit tests
│   ├── repository/         # Drift SQLite integration tests
│   └── widget/             # Flutter widget tests
├── assets/
│   ├── icons/              # App icon, drill card icons
│   └── fonts/              # IndieFlower custom font
├── android/                # Android platform config
├── ios/                    # iOS platform config
├── docs/                   # Knowledge transfer documents (this directory)
├── spec.md                 # Full product specification
├── prompt_plan.md          # 28-step build plan (historical record)
├── todo.md                 # Milestone checklist
└── DEVELOPER_NOTES.md      # Implementation decisions and technical notes
```

---

## Key Config Files

| File | What it controls |
|------|-----------------|
| `pubspec.yaml` | Dependencies, assets, fonts |
| `android/app/build.gradle.kts` | Android build config (min SDK, target SDK, signing) |
| `ios/Runner/Info.plist` | iOS permissions, orientation lock, bundle metadata |
| `analysis_options.yaml` | Lint rules (extends `flutter_lints`) |

---

## Branching and Commits

- Never commit directly to `main`.
- All work goes on feature branches. Merge back via PR.
- Never use `git commit --no-verify`. Pre-commit hooks exist for a reason.
- Every file must start with two `ABOUTME:` comment lines.
- Run `flutter test` and `flutter analyze` before pushing.

---

## App Icon Generation

App icons are generated from `assets/icons/hermit-crab.png` using `flutter_launcher_icons`. The generated icons are checked into the repo, so you don't need to run this normally. If you update the source icon:

```bash
dart run flutter_launcher_icons
```

---

## Reading the Spec

Before starting any feature work, read `spec.md`. It is the authoritative product specification. It describes every drill, every tool, and every setting in detail. The codebase was built to match it. If code and spec disagree, the spec is the source of truth unless there's a documented reason for the deviation.
