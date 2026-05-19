# Hermit Prov — The Drill System

The drill system is the core of Hermit Prov. Understanding it top-to-bottom is the most important thing a new developer can do. This document walks through every layer: domain model, state machine, shell widget, and individual drill implementations.

---

## Concepts

**Drill:** A named practice exercise with configurable settings, a session timer, and optional TTS hands-free mode.

**Segment:** One timed phase within a drill session. Most drills have two types:
- `speaking` / `timed` — the performer is actively practicing
- `regroup` — a rest period between reps

**Loop:** When all segments complete, the drill can either end (finite) or restart from the first segment (looping).

**Session:** One continuous run of a drill. Logged to history when it's 30+ seconds long.

---

## Layer 1: DrillId

```dart
// lib/domain/drills/drill_id.dart
enum DrillId {
  catClock,
  characterCreation,
  twoCharacterScenes,
  atoC,
  fiveLineGame,
}
```

The `displayName` extension provides human-readable names. Every `switch` on `DrillId` must be exhaustive — the compiler enforces this.

---

## Layer 2: DrillSettings

Each drill has its own settings class, all subclasses of the sealed `DrillSettings`:

```dart
sealed class DrillSettings { ... }
class CatClockSettings extends DrillSettings { ... }
class CharacterCreationSettings extends DrillSettings { ... }
class TwoCharacterScenesSettings extends DrillSettings { ... }
class AtoCSettings extends DrillSettings { ... }
class FiveLineGameSettings extends DrillSettings { ... }
```

All settings classes:
- Have factory constructors: `defaults()` and `fromJson(Map)`
- Have `toJson()` for persistence
- Expose a `handsFreeModeEnabled` bool

`DrillSettings.defaultsFor(DrillId)` returns the default settings for any drill.

Settings are persisted per-drill in SQLite as JSON blobs (`DriftDrillSettingsRepository`). If no row exists, `defaultsFor` is returned.

---

## Layer 3: DrillSegment

```dart
class DrillSegment {
  final String id;
  final DrillSegmentType type;   // speaking, regroup, timed
  final Duration duration;
  final String? promptPayload;   // null during regroup/return segments
  final String? label;           // e.g. "Character 1" for character creation
}
```

A list of `DrillSegment`s is the full recipe for one drill run. Each drill has a builder class that converts settings into a segment list:

| Drill | Builder class | Segments per run |
|-------|--------------|-----------------|
| Cat/Clock | `CatClockSequenceBuilder` | 2 (speaking + regroup) |
| Character Creation | `CharacterCreationCycleBuilder` | 2N (N first-pass + N return-pass) |
| Two-Character Scenes | `TwoCharacterSequenceBuilder` | 2 (scene + regroup) |
| A-to-C | `AtoCSequenceBuilder` | 1 (timed) |
| Five Line (auto) | N/A — directly creates 1-segment list | 1 |

The session screen calls the builder, passes the resulting list to `DrillSessionController`, and hands the controller to `DrillSessionShell`.

---

## Layer 4: DrillSessionController (Pure Dart State Machine)

```dart
// lib/domain/drills/drill_session_controller.dart
class DrillSessionController {
  DrillSessionState get state => _state;

  void start() { ... }
  void pause() { ... }
  void resume() { ... }
  void stop() { ... }   // terminal — sets status to stopped
  void reset() { ... }  // restores to full DrillSessionState.initial()
  void tick() { ... }   // advance elapsed time by tickDuration (default: 1s)
}
```

**Key design decision:** The controller has no real timer inside it. It advances by `tickDuration` each time `tick()` is called. The Flutter widget layer (`DrillSessionShell`) is responsible for calling `tick()` once per second using a `Timer.periodic`. This makes the controller 100% unit-testable without fake timers or async.

**Status lifecycle:**

```
idle → running → paused → running → completed (finite drills)
                         → stopped (any time Stop is pressed)
idle → running → ... → stopped

reset() always returns to idle regardless of current status
```

**`stop()` vs `reset()`:**
- `stop()` is terminal — status becomes `stopped`; the session screen calls `onSessionEnd()` which pops the route
- `reset()` restores full initial state — status becomes `idle`, all elapsed times zero, ready for Start again
- The Stop button in `DrillSessionShell` calls `reset()` (which logs the session, then resets), NOT `stop()`. `stop()` is only called when the session truly ends (completes or user exits).

---

## Layer 5: DrillSessionState

```dart
class DrillSessionState {
  final DrillSessionStatus status;
  final List<DrillSegment> segments;
  final int currentSegmentIndex;
  final Duration segmentElapsed;
  final Duration sessionElapsed;
  final int loops;

  // Derived properties
  DrillSegment get currentSegment => segments[currentSegmentIndex];
  Duration get segmentRemaining => currentSegment.duration - segmentElapsed;
  double get segmentProgress => segmentElapsed.inMilliseconds / currentSegment.duration.inMilliseconds;

  bool get isIdle => status == DrillSessionStatus.idle;
  bool get isRunning => status == DrillSessionStatus.running;
  bool get isPaused => status == DrillSessionStatus.paused;
  bool get isCompleted => status == DrillSessionStatus.completed;
  bool get isStopped => status == DrillSessionStatus.stopped;
  bool get isActive => isRunning || isPaused;
}
```

All properties are immutable. `tick()` replaces `_state` with a new `DrillSessionState` instance.

---

## Layer 6: DrillSessionShell (Reusable Session UI)

```dart
// lib/features/practice/drill_session_shell.dart
class DrillSessionShell extends StatefulWidget {
  final DrillSessionController controller;
  final Widget Function(DrillSessionState) contentBuilder;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;
  final bool autoStart;
}
```

`DrillSessionShell` is the one-size-fits-all session UI. It:
- Owns a `Timer.periodic` that calls `controller.tick()` every second
- Calls `setState` after each tick so Flutter rebuilds with the new state
- Renders the circular countdown ring and progress indicator
- Renders the Start / Pause / Resume / Stop-or-Exit button
- Calls `contentBuilder(state)` to render the drill-specific content (prompt text, character labels, etc.)
- Calls `_maybeLogSession()` before resetting — logs to `PracticeHistoryRepository` if `sessionElapsed >= 30s`

The session screens (e.g. `CatClockSessionScreen`) don't deal with timers or controls at all. They just build a `DrillSessionController`, define a `contentBuilder`, and hand both to `DrillSessionShell`.

**The Configure button:** Each drill session screen receives an `onConfigure` callback. `DrillSessionShell` renders a gear icon in the app bar if `onConfigure` is non-null. After configure returns, `PracticeScreen` restarts the session with fresh settings.

---

## Layer 7: Per-Drill Session Screens

Five session screens, each following the same pattern:

```dart
class CatClockSessionScreen extends StatefulWidget {
  final CatClockSettings settings;
  final PromptRepository promptRepository;
  final PracticeHistoryRepository historyRepository;
  final TtsService ttsService;
  final VoidCallback onSessionEnd;
  final VoidCallback onConfigure;
}
```

All dependencies are passed in (not fetched via `AppServices.of(context)` inside the screen). This makes widget testing straightforward — inject what you need, no context required.

The session screen's job:
1. Build the segment list using the drill's sequence builder
2. Fetch any needed prompts asynchronously
3. Create a `DrillSessionController` from the segment list
4. Define `contentBuilder` (what to show inside the countdown ring)
5. Hand everything to `DrillSessionShell`
6. Handle prompt regeneration on loop completion (for looping drills)

---

## Prompt Loading

Prompts are fetched from `PromptRepository` using `PromptPicker`:

```dart
// lib/domain/prompts/prompt_picker.dart
class PromptPicker {
  static Future<String> pick(
    PromptRepository repo,
    List<PromptCategory> categories,
  ) async { ... }
}
```

`PromptPicker` draws from the union of built-in prompts and custom user prompts matching the requested categories. It picks randomly and returns the text only (not the full model).

For looping drills (Cat/Clock, Two-Character, A-to-C), a new prompt is fetched on each loop boundary. The session screen listens for loop boundaries via the controller state and regenerates.

---

## Hands-Free Mode (TTS)

`HandsFreeAnnouncementPolicy` decides what to announce at each tick. The drill session shell checks the policy after every `tick()` and calls `ttsService.speak()` if the policy says to.

**Announcement rules (from the policy):**
- On segment start: speak the segment's prompt/label
- For segments longer than 30 s: speak countdown at 30 s remaining, 10 s remaining, and 5-4-3-2-1
- For segments ≤ 30 s: skip countdown announcements (they'd overlap with the prompt)

`FakeTtsService` is always used in tests so no audio output occurs.

---

## Session Flow: Cat/Clock Example

```
User taps Cat/Clock card
  → PracticeScreen._startDrill(DrillId.catClock)
  → Fetches CatClockSettings from DrillSettingsRepository
  → Pushes CatClockSessionScreen

CatClockSessionScreen.initState()
  → Fetches 2 prompts via PromptPicker
  → Builds [speakingSegment, regroupSegment] via CatClockSequenceBuilder
  → Creates DrillSessionController with those segments

CatClockSessionScreen.build()
  → Renders DrillSessionShell(controller, contentBuilder: ...)
  → contentBuilder shows: word1 + word2 + "New Words" button during speaking segment
  → contentBuilder shows: blank during regroup

DrillSessionShell manages:
  → Timer.periodic calling controller.tick() every second
  → Countdown ring redraw
  → Start/Pause/Resume/Stop buttons

When loop completes:
  → CatClockSessionScreen fetches 2 new prompts
  → Calls setState to update the displayed words

When Stop pressed:
  → DrillSessionShell._maybeLogSession() (logs if ≥ 30s)
  → controller.reset() (restores idle state)
  → If user taps Exit (idle state): controller.stop(), onSessionEnd() called, Navigator.pop()
```

---

## Five Line Scenes: The Special Case

Five Line Scenes has two modes controlled by `FiveLineGameSettings.autoAdvance`:

**Manual mode (`autoAdvance = false`):**
- No `DrillSessionController`, no `DrillSessionShell`
- Just a `Scaffold` with the prompt centered + a "New Prompt" button
- No timer, no session logging
- User taps as fast or slow as they want

**Auto-advance mode (`autoAdvance = true`):**
- Uses `DrillSessionController` (single-segment looping) + `DrillSessionShell`
- New prompt fetched on each loop boundary via `addPostFrameCallback`
- Full hands-free TTS, session logging, countdown ring

When switching between modes in configure, the session is restarted with fresh settings.

---

## Configure Screens

Each drill has a configure screen (`CatClockConfigureScreen`, etc.). They all share `DrillConfigureScreen` as a scaffold (title, Save button in app bar). The drill-specific fields are passed as a `body` widget.

Configure screens:
1. Load current settings from `AppServices.of(context).drillSettingsRepository`
2. Show sliders, dropdowns, toggles
3. On Save: write updated settings back to the repository and `Navigator.pop()`

After configure returns, `PracticeScreen._restartWithFreshSettings()` pops the current session and re-launches it with the updated settings loaded from the repository.

---

## Adding a New Drill (Checklist)

1. Add a new value to `DrillId` enum — the compiler will immediately flag all exhaustive switches that need updating
2. Create `YourDrillSettings extends DrillSettings` with `defaults()`, `toJson()`, `fromJson()`
3. Create a sequence builder in `lib/domain/drills/your_drill/`
4. Create `your_drill_session_screen.dart` and `your_drill_configure_screen.dart`
5. Add the drill to `PracticeScreen._drills` list
6. Add cases to `PracticeScreen._startDrill()` and `_configureDrill()`
7. Update `DrillSettings.defaultsFor()` and `fromJson()`
8. Write unit tests for the sequence builder
9. Write widget tests for the session screen and configure screen
