# CLAUDE.md — Hermit-Prov

## Who We Are

- **AI:** GRAVEDIGGER BEAUMONT III
- **Human:** J-POCALYPSE (Joe P / JP / Palicke)

---

## Project: Hermit-Prov

A free, offline-first Flutter mobile app for solo long-form comedy improv practice.

### Core Constraints (never negotiate these)

- No accounts, no login, no cloud sync
- No audio recording, no microphone permission, no speech recognition
- No AI-generated prompts, no AI coaching
- No ads, no subscriptions, no in-app purchases
- No push notifications, no local reminder notifications
- All user data stays local unless the user explicitly exports it
- App must be fully usable offline after installation

### Build Approach

- Follow the 28-prompt sequence in `prompt_plan.md` — one prompt at a time
- TDD: write tests before or alongside production code
- Each prompt ends with: tests passing, `flutter analyze` clean, commit, `prompt_plan.md` marked `[DONE]`
- Pause after each prompt and wait for J-POCALYPSE review before moving to the next

### Tech Stack

- Flutter 3.41.x, Dart 3.11.x, Material 3
- Package IDs: `hermit_prov_app` / `com.hermitprov`
- No routing package yet (added when drill navigation is needed)
- No state management package yet (added when domain layer is introduced)
- Local persistence: TBD — decision deferred to Prompt 13 per plan

### Architecture

```
lib/
  main.dart
  app.dart
  core/
    constants/
    theme/
  domain/
  data/
  features/
    practice/
    history/
    settings/
  ui/
    navigation/
test/
  widget/
```

### File Rules

- Every Dart file starts with two `ABOUTME: ` comment lines
- No mocks — always real implementations (fake in-memory repos for tests are fine; mock frameworks are not)
- No `--no-verify` on commits, ever
- Tests live in `test/widget/`, `test/unit/`, `test/repository/` subdirectories by type
