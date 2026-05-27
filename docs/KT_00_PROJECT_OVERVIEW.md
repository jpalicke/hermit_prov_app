# Hermit Prov — Project Overview

## What Is This?

Hermit Prov is a free, offline-first Flutter mobile app for **solo long-form comedy improv practice**. It is designed for improvisers who want to practice alone, at home, without a scene partner. The app provides structured drills, tools (suggestion generator, timer, emotion wheel), and a journal to track progress.

The app targets Android and iOS. A web build exists (`lib/web/web_app.dart`) but is not a primary target and is not published.

---

## The Name

"Hermit" — practicing alone. "Prov" — short for improv. A hermit crab is the app's mascot.

---

## Core Constraints (Non-Negotiable)

These are not preferences. Every feature decision must be made within these boundaries:

| Constraint | Why |
|------------|-----|
| No accounts, no login, no cloud sync | The app works fully offline after install |
| No audio recording, no microphone permission | Privacy; no speech recognition needed |
| No AI-generated prompts or coaching | Human-curated content only |
| No ads, no subscriptions, no in-app purchases | Free forever |
| No push or local reminder notifications | User decides when to practice |
| All user data stays local unless the user explicitly exports it | Privacy-first design |
| App must be fully usable offline after installation | No network dependency |

If anyone asks you to add a feature that violates one of these constraints, the answer is no.

---

## Feature Summary

### Drills (5 total)

All drills are structured practice sessions with a configurable timer and optional TTS (text-to-speech) hands-free mode:

| Drill | What it does |
|-------|-------------|
| **Cat/Clock** | Connect two random words through free-association monologue |
| **Character Creation** | Create N characters in sequence, then cycle back through them |
| **Two-Character Scenes** | Timed scenes with a single suggestion; performer plays both characters |
| **A-to-C** | Rapid-fire initiation practice — new suggestion every N seconds |
| **Five Line Scenes** | Short scenes with a suggestion; manual or auto-advance mode |

### Tools

Standalone utilities accessible from the Practice tab's "Tools" card:

- **Suggestion Generator** — pick a random prompt from selected categories on demand
- **Suggestion Bank** — manage your custom user-added prompts (add/edit/delete)
- **Journal** — freeform notes, optionally tagged to a drill
- **Timer** — simple countdown or Work/Rest interval timer
- **Emotion Wheel** — interactive Glenn Trigg Emotions Wheel (CC BY 4.0)

### Settings

- Light / dark / system theme
- TTS speaking rate
- Reset drill defaults
- Export / import data (JSON backup)
- Privacy and About screen
- Reset all data (danger zone)

---

## Tech Stack

| Technology | Version | Role |
|------------|---------|------|
| Flutter | 3.41.x | UI framework |
| Dart | 3.11.x | Language |
| Material 3 | — | Design system |
| Drift | 2.33.x | Type-safe SQLite ORM (generated DAO) |
| SharedPreferences | 2.5.x | Light key-value persistence (theme, TTS rate) |
| flutter_tts | 4.2.x | Text-to-speech for hands-free mode |
| url_launcher | 6.3.x | Opens links in Privacy/About screen |
| share_plus | 10.1.x | Shares backup JSON via OS share sheet |
| file_picker | 8.1.x | Picks backup file for import |
| font_awesome_flutter | 11.x | FontAwesome icons |

**No routing package** — navigation is done with direct `Navigator.push` / `MaterialPageRoute` calls.  
**No state management package** — dependency injection uses a single `InheritedWidget`; state is managed with `StatefulWidget` and a pure-Dart state machine.

---

## The Build Plan

The app was built using a 28-prompt sequential plan (`prompt_plan.md`). All 28 prompts are complete. Each prompt added a slice of functionality and required all tests to pass and `flutter analyze` to be clean before moving to the next.

The `prompt_plan.md` file serves as a detailed build log. If you need to understand why something was built a certain way, it's the best historical record.

---

## People and Credits

- **Developer:** Joe Palicke (jpalicke on GitHub)
- **Glenn Trigg Emotion Wheel:** Licensed CC BY 4.0, used with attribution
- **Hermit crab icon:** Designed by paulalee from Flaticon
- **Cat icon:** Designed by Marz Gallery from Flaticon

---

## Platforms

| Platform | Status |
|----------|--------|
| Android | Primary target; automated release workflow builds signed AAB and publishes to Play Store |
| iOS | Primary target; automated release workflow builds IPA and submits to App Store Connect |
| Web | Build exists (`lib/web/web_app.dart`) but not published or maintained |
| Desktop | Not supported |

---

## Open Issues at Handoff

See `docs/KT_06_OPEN_ISSUES.md` for a full list. The short version:

1. Crash reporting is coded but not wired up
2. Android release signing: CI workflow (`android-release.yml`) handles this via GitHub secrets; local release builds still need a `key.properties` file
3. `DEVELOPER_NOTES.md` has stale entries
4. `todo.md` milestone completion state is not fully up to date
5. Tablet/iPad layout has not been decided
