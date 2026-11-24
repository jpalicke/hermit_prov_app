# Hermit Prov — Project Retrospective

**Team:** GRAVEDIGGER BEAUMONT III (AI) + J-POCALYPSE (Joe P)  
**Project duration:** Start to v1 complete  
**Final state:** 28 prompts done, 361 tests passing, flutter analyze clean

---

## Everything We Built

### Phase 0 — Foundation

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 1 | Flutter project scaffold, app shell, bottom navigation (Practice / History / Settings), initial widget tests |
| Design pass | IndieFlower font (bundled as asset), Material 3 seed color #7C3AED (vivid violet), drill card accent colors, Font Awesome icons |
| Prompt 2 | Practice home with drill cards and placeholder routing, CLAUDE.md with team names |
| Removed google_fonts | Switched from google_fonts package to bundled font asset to avoid network dependency |
| Removed desktop platforms | Deleted linux/macos/windows platform scaffolds (flutter create generates them; not needed) |

### Phase 1 — Domain Models

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 3 | Domain models and repository interfaces: DrillId, DrillSettings sealed hierarchy (5 subclasses), PromptCategory enum, BuiltInPrompt, CustomPrompt, PracticeSession, JournalEntry, AppPreferences |
| Post-review fixes | Refined domain models after Joe P review pass |
| Prompt 4 | In-memory repository implementations for all 5 repositories; AppServices InheritedWidget DI |
| Added genre + events categories | Expanded from 6 to 8 prompt categories (objects, locations, relationships, occupations, emotions, activities, genre, events) |
| Fresh-eyes fixes | Prompt 4 fixes from fresh-eyes review pass |

### Phase 2 — Prompt System

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 5 | PromptPicker (random selection across categories), CustomPromptValidator (slur/explicit blocklist), full seed prompt content (1,661 total prompts across 8 categories) |
| Removed slur descriptions | Cleaned validator test descriptions that had contained the actual slur words |
| Prompt 6 | Custom Prompt CRUD: list screen with swipe-to-delete, add/edit screen, category picker |
| Prompt 7 | Standalone Prompt Generator tool: category filter chips, single-tap generation, auto-advance timer option |

### Phase 3 — Drill Engine

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 8 | Pure-Dart drill session engine: DrillSegment, DrillSessionState, DrillSessionController (tick-driven state machine, no Flutter deps), full unit test suite |
| Prompt 9 | Reusable DrillSessionShell widget: circular countdown ring, Start/Pause/Resume/Stop controls, 30-second session logging threshold, contentBuilder pattern |
| Hermit crab app icon | Generated app icons from hermit-crab.png (Flaticon, paulalee) |
| Cat/Clock objects default | Set Cat/Clock default category to objects; added "New Words" button for mid-rep regeneration |

### Phase 4 — All Five Drills

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 10 | Cat/Clock drill: configure screen (speaking/regroup duration, category selectors, hands-free toggle), session screen (dual-word display, loop-refresh prompts) |
| Prompt 11 | Two-Character Scenes drill: configure (scene/regroup duration, category selector), session (single suggestion, blank regroup) |
| Prompt 12 | A-to-C drill: configure (interval selector), session (rapid-fire single prompt, looping) |
| Prompt 13 | Five Line Scenes: configure (auto-advance toggle + interval), manual mode (no timer, just "New Prompt"), auto-advance mode (DrillSessionShell with timed loop) |
| Prompt 14 | Character Creation cycle domain logic: CharacterCreationCycleBuilder generates 2N segments (N first-pass + N return-pass), per-character prompt assignment |
| Prompt 15 | Character Creation UI: first-pass shows prompt + character label + "New Prompt" button; return-pass shows character label only; finite session |

### Phase 5 — UX Polish

| Commit/Task | What was done |
|-------------|---------------|
| Remove drill start screens | Replaced two-step (card → start screen → session) with one-step (card tap → session), gear icon for configure |
| Remove stop dialog | Eliminated confirmation dialog on stop — Stop just stops, no "are you sure?" |
| Always-visible configure button | Configure gear visible at all times during session (not just on idle screen) |
| Manual timer start | Sessions no longer auto-start; user must tap Start explicitly |
| Fix configure changes not taking effect | Bug: configure changes weren't propagating to active sessions; fixed by restarting session on configure return |
| UX polish round 2 | Auto-start option for drills, instructions modal system, Prompt Generator overhaul |
| Remove custom prompt count badges | Category chip badges were more confusing than helpful; removed |

### Phase 6 — Persistence

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 13 (persistence milestone) | Drift SQLite database: 4 tables (CustomPrompts, DrillSettingsTable, PracticeSessions, JournalEntries); DriftPromptRepository, DriftDrillSettingsRepository, DriftPracticeHistoryRepository, DriftJournalRepository; SharedPreferencesAppPreferencesRepository; AppServices.withLocalStorage() production factory |

### Phase 7 — Tools and History

| Commit/Task | What was done |
|-------------|---------------|
| Prompts 19+20 | Practice History: 30-second logging threshold, PracticeStats.compute() (total time, sessions, current/longest streak, per-drill breakdown), HistoryScreen; Practice Journal: CRUD with drill tag, JournalScreen, JournalEntryScreen |
| Prompt 21 | Standalone Timer: simple countdown + Work/Rest interval modes; uses DrillSessionController internally; inline config-to-running transition |
| Prompt 22 | Interactive Emotion Wheel: CustomPainter with 3 concentric arc rings (core/mid/outer), InteractiveViewer zoom (1x–5x), tap-to-select, random picker with ring filter |

### Phase 8 — TTS, Settings, Privacy, Crash

| Commit/Task | What was done |
|-------------|---------------|
| Prompts 16+17+18 | TtsService interface, FlutterTtsService production impl, FakeTtsService for tests; HandsFreeAnnouncementPolicy (pure Dart, unit-tested); hands-free mode wired into all 5 drills |
| Prompt 23 | Settings screen: theme selector (system/light/dark), TTS settings screen (speaking rate slider, TTS enable toggle), drill defaults reset, data backup section |
| Prompt 25 | Privacy and About screen: data practices, credits (Glenn Trigg, Flaticon attributions), support email link, Ko-fi donate link |
| Prompt 26 | Crash report domain + data layer (CrashReport model, CrashPayloadSanitizer, NoOpCrashReportService, CrashReportDialog widget) |

### Phase 9 — Backup and Polish

| Commit/Task | What was done |
|-------------|---------------|
| Prompt 24 | JSON export/import backup: AppBackup model, LocalBackupService, export via share_plus, import via file_picker, merge-with-skip-duplicate logic |
| Prompt 27 | Accessibility: Semantics wrappers on all interactive elements, Tooltip on icon buttons, header semantics on section headers; portrait lock on Android + iOS; permissions audit (confirmed clean) |
| Prompt 28 | Final integration: v1 acceptance tests, edge case fixes, cleanup |

### Post-Build Fixes and Copy

| Commit/Task | What was done |
|-------------|---------------|
| Fix duplicate seed prompts | Found and removed duplicate entries in events and genre categories |
| Remove redundant seed prompt | Removed 'a school reunion' (duplicate of 'a class reunion') |
| Fix Flaticon attribution | Tracked down correct designer names for hermit crab and cat icons |
| TTS voice selection removal | Removed TTS voice selector entirely after chasing multiple bugs; kept speaking rate only |
| App name consistency | Resolved Hermit Prov / Hermit-Prov naming inconsistency across all files |
| Various hands-free fixes | Fixed 4 TTS/hands-free issues found in integration testing |
| Stop/Reset fix | Fixed Stop button leaving drill in un-restartable `stopped` state; added `reset()` to controller |
| History not loading | Fixed history screen not refreshing after drill sessions (two-part fix: ValueKey pattern + reset() fix) |
| Rename Five Line Game Drill | Renamed to "Five Line Scenes" |
| Rename Prompt Generator | Renamed to "Suggestion Generator" |
| Rename Custom Prompts | Renamed to "Add words to the suggestion bank" |
| Updated all taglines | Updated drill and tools subtitles to Joe P's preferred copy |
| Updated settings copy | Updated TTS subtitle and data backup notice text |
| Fixed Ko-fi URL | Corrected ko-fi.com link to ko-fi.com/joepalicke |
| Created GitHub issues | Created issues #1–#5 for known gaps at handoff |
| Created KT docs | This document and the full docs/ knowledge transfer suite |

---

## What Worked

### The 28-Prompt Sequential Plan

The most important success of this project. Having a fully-articulated plan before writing a line of code meant every session had a clear, bounded objective. Each prompt was small enough to complete in one session, large enough to deliver visible progress. Working through them in order meant nothing was built speculatively — every piece was wired in immediately.

### Pure-Dart State Machine for Drills

The `DrillSessionController` design — no real timer, driven by explicit `tick()` calls — turned out to be the right call for the most complex domain object in the app. It's fully unit-testable without fake timers, async test utilities, or mocking. The tests are fast and deterministic. This paid off immediately and every time a drill behavior needed to change.

### Sealed Class for DrillSettings

The `sealed class` hierarchy means the Dart compiler enforces exhaustive handling of drill types everywhere they're switched on. When the Character Creation drill was added, the compiler immediately pointed to every switch that needed a new case. No silent regressions.

### Dual Storage Modes (in-memory for tests)

`AppServices.withInMemory()` wiring all test implementations in a single call was clean and effective. Every widget test gets a fresh in-memory store with no disk I/O. Tests are fast, isolated, and don't interfere with each other.

### InheritedWidget DI Instead of a Package

Choosing not to add Riverpod, BLoC, or any state management package kept the codebase simple. The single `AppServices` InheritedWidget is easy to understand and works correctly for everything the app needs. A junior developer can read it and understand it immediately.

### TDD Discipline

Writing tests first kept logic clean and caught bugs early. The 30-second session logging threshold, the announcement policy rules, the stat calculation — all of these were tested before being integrated into widgets. This made integration smooth.

### Feature Branches

Batching related prompts onto feature branches (e.g. `feature/tts-hands-free`, `feature/practice-history`) reduced merge noise and gave natural review points.

---

## What Went Wrong

### 1. TTS Voice Selection (Multiple commits, eventually abandoned)

**What happened:** Multiple sessions were spent trying to make TTS voice selection work correctly — filtering by Enhanced quality, handling non-en-US locales, fixing voice list behavior. Eventually the feature was cut entirely and replaced with speaking-rate-only control.

**Root cause:** TTS voice APIs are inconsistent across Android and iOS versions. The feature was more complex than the value it delivered.

**Impact:** Several commits of work discarded, DEVELOPER_NOTES.md now has stale entries about this feature.

**How to prevent:** When a third-party API feature proves platform-inconsistent after one debugging session, escalate the go/no-go decision immediately rather than spending more sessions on it. Set a one-session timebox on platform-specific debugging.

---

### 2. Stop Button Dead-End State (Multi-session bug)

**What happened:** `DrillSessionShell._handleResetToIdle()` called `controller.stop()` instead of `controller.reset()`. `stop()` sets status to `stopped` (terminal). After pressing Stop, the session was permanently stuck — `isIdle` never became true, the "Exit" button never appeared, the user was trapped.

**Root cause:** `stop()` and `reset()` were different methods with different semantics, but their names didn't make the distinction obvious. `reset()` didn't exist until this bug was found.

**Impact:** History wasn't being logged correctly; the Stop button was broken; took multiple sessions to diagnose and fix.

**How to prevent:** When a state machine has terminal vs. recoverable exits, name them explicitly in domain design. `stop()` = terminal, `reset()` = recoverable — this distinction should be in the doc comment on both methods.

---

### 3. History Not Refreshing (Related to bug #2, separate cause)

**What happened:** Even after fixing the Stop/reset flow, history wasn't refreshing on the History tab. The `HistoryScreen` `_initialized` guard prevented re-fetching because `IndexedStack` keeps all tabs mounted permanently.

**Root cause:** `IndexedStack` never destroys the History widget, so `_initialized` was set to true once and never reset. The widget's data never refreshed.

**Fix:** Added `_historyVersion` counter on `BottomNavShell`; incrementing it and using it as a `ValueKey` on `HistoryScreen` forces Flutter to recreate the widget (and clear `_initialized`) on every History tab visit.

**How to prevent:** When using `IndexedStack`, document explicitly that mounted tabs won't be recreated on switch. Any screen that needs to reload data on each visit needs the `ValueKey` pattern or a stream/reactive approach. This should be in the architecture doc (it now is).

---

### 4. Assumption Without Checking (Hard rule established)

**What happened:** Made a claim that the app icon was "almost certainly still the default Flutter blue logo" without checking. The icon was in fact custom — a 93KB hermit crab PNG. Joe P called this out in the strongest terms.

Separately: stated that "Milestone 26 is entirely unimplemented" based on unchecked todo.md checkboxes, when the domain/data/feature layers all existed. The gap was that it wasn't wired up, not that it didn't exist.

**Root cause:** Making statements about codebase state without verifying with tools. Every needed tool was available.

**Impact:** Eroded trust; wasted time on incorrect analysis.

**Rule now in effect:** Never state a fact about the codebase without reading the file, running the grep, or checking the asset first. No hedging with "probably" or "almost certainly." Present findings, not guesses. Saved to memory: "Never assume anything about the codebase without verifying it with tools first. Joe P said 'I'd yeet a human developer into the sun for that.'"

---

### 5. Seed Prompt Content Lost to Context Compaction

**What happened:** Word lists for multiple seed categories (objects, locations, genre, events) were drafted in conversation before being written to disk. When context compaction occurred, the drafted content was lost.

**Root cause:** Large content blocks generated in chat are vulnerable to context compaction before the Write tool is called.

**Impact:** Joe P's collaborative work reviewing and refining word lists was lost and had to be partially re-done.

**Rule now in effect:** The moment any word list or large content block is ready, call Write immediately. Never draft large content in conversation. Content first hits disk, then is shown to the user. Saved to memory.

---

### 6. Emotion Wheel Work Re-Derived Instead of Recovered from Transcript

**What happened:** When context was lost after a session that had confirmed emotion wheel boundary words, sector counts, and deduplication rules through careful back-and-forth, the next session re-derived the data from scratch by re-reading the source image instead of checking the session transcript.

**Root cause:** Didn't know to check the JSONL transcript for prior confirmed outputs before re-reading source material.

**Impact:** Discarded J-POCALYPSE's time investment in the confirmation session; produced inferior results.

**Rule now in effect:** Before re-reading any source material after context loss, search the session transcript for confirmed prior outputs. Saved to memory.

---

### 7. Committed Directly to Main/Master

**What happened:** At least one prompt's implementation was committed directly to main without going through a feature branch.

**Root cause:** Agent spawning didn't use `isolation: "worktree"` by default.

**Rule now in effect:** All implementation work on feature branches. Agents spawned for implementation must use a branch. Saved to memory.

---

### 8. Planning Docs Not Updated at Completion

**What happened:** Multiple milestones in `todo.md` were left unchecked after implementation. `DEVELOPER_NOTES.md` accumulated stale entries (tts_voice key, backup schema ttsVoice field, voice selection QA step). The documentation lagged the code throughout the project.

**Root cause:** The definition of "done" for a prompt was "tests pass, analyze clean, commit" — it didn't include updating planning docs.

**Rule now in effect:** A milestone is not complete until all planning documents (`todo.md`, `prompt_plan.md`) and documentation (`DEVELOPER_NOTES.md`, manual QA checklist) are updated. This is now part of the definition of done.

---

### 9. Declared Defeat Too Early on Attribution

**What happened:** Spent multiple sessions saying the Flaticon icon author couldn't be found via WebFetch (getting 403s), when a Google search combined with the chrome-devtools MCP would have resolved it.

**Root cause:** Announced failures too early without exhausting alternatives. `WebFetch returned 403` ≠ "information is unavailable."

**Rule now in effect:** Never tell Joe P something can't be done without first trying a web search for alternatives. Dead ends should be exhausted silently, not announced as failures. Saved to memory.

---

### 10. Crash Reporting Never Wired Up

**What happened:** All the code for crash reporting was written (domain, data, feature layers) but never connected. `CrashReportService` isn't in `AppServices`, and `main.dart` has no error handler. The dialog will never fire.

**Root cause:** The implementation prompt produced the code but didn't include a validation step that confirmed the feature actually activated end-to-end.

**How to prevent:** Any feature that requires multiple wiring points (code + DI + entry point) should have an end-to-end test that confirms activation, not just a test that the individual pieces work in isolation. An acceptance test that forces an exception and asserts the crash dialog appears would have caught this immediately.

---

## Process Improvements for Future Work

| # | Improvement | Applies to |
|---|-------------|-----------|
| 1 | **Updated definition of done:** tests pass + analyze clean + planning docs updated + DEVELOPER_NOTES.md current | Every prompt/milestone |
| 2 | **Verify before stating:** Always grep/read before making any claim about code state | Every session |
| 3 | **Write large content immediately:** Any word list, large block, or generated content goes to disk before being shown in chat | Seed content, any long-form generation |
| 4 | **Check transcript before re-deriving:** After context loss, search JSONL before re-reading source material | Any session after compaction |
| 5 | **Timebox platform-specific debugging:** One session max on inconsistent third-party API behavior; escalate go/no-go | TTS, platform plugins, native features |
| 6 | **End-to-end test for multi-wire features:** Features requiring DI wiring + entry point hooking need an activation test | Crash reporting; any future service integration |
| 7 | **IndexedStack reload pattern in architecture docs:** Document the ValueKey pattern when using IndexedStack with data-fetching screens | Navigation architecture decisions |
| 8 | **Feature branches by default:** All work on branches; never commit to main directly | Git workflow |
| 9 | **Exhaust alternatives before declaring failure:** Try web search before announcing something can't be done | Any blocked task |
| 10 | **State machine terminal vs. recoverable exits:** Document explicitly in code which exits are terminal and which are recoverable | Any future state machines |

---

## Numbers

| Metric | Value |
|--------|-------|
| Total prompts in plan | 28 |
| Prompts completed | 28 (100%) |
| Test files | 44 |
| Tests at handoff | 361 passing |
| Flutter analyze issues | 0 |
| Production Dart files | ~90 |
| Seed prompt categories | 8 |
| Total built-in seed prompts | 1,661 |
| Git commits | 60 |
| Open GitHub issues | 5 |
| Time to v1 | One project, complete |
