# Hermit-Prov Implementation Blueprint and Codegen Prompts

This document converts the **Hermit-Prov Developer Handoff Spec** into a step-by-step implementation blueprint and a sequence of prompts for a code-generation LLM.

The goal is to build Hermit-Prov incrementally, test-first, with each step producing integrated, shippable progress. No step should leave orphaned code that is not wired into the existing app.

---

# Part 1 — Implementation Philosophy

Hermit-Prov should be built in narrow vertical slices.

Each implementation step should:

1. Start with tests or testable acceptance criteria.
2. Add only the minimum production code needed for that step.
3. Wire the new code into the app immediately.
4. Avoid speculative architecture that is not yet used.
5. Keep local-only/offline behavior intact.
6. Preserve the permanent no-AI, no-recording, no-cloud-sync product philosophy.

The project should favor correctness and testability over cleverness.

Recommended development style:

- Flutter preferred.
- Keep business logic outside widgets where possible.
- Use local persistence abstractions early, but do not overbuild them.
- Treat timers, drill flows, export/import, prompt validation, and history logging as testable domain logic.
- UI can be simple early, but every feature should be wired into real screens as soon as it exists.

---

# Part 2 — Suggested Technical Architecture

The handoff spec leaves exact implementation details to the developer, but the code-generation prompts below assume a Flutter app with a layered architecture.

A developer may choose different packages, but the architecture should preserve the same boundaries.

## 2.1 Recommended Layers

```text
lib/
  main.dart
  app.dart

  core/
    constants/
    result/
    time/
    validation/
    storage/
    export_import/
    accessibility/

  domain/
    prompts/
    drills/
    history/
    journal/
    settings/
    tts/
    privacy/

  data/
    repositories/
    local/
    seed/

  features/
    practice/
    drill_session/
    tools/
    history/
    settings/

  ui/
    components/
    theme/
```

## 2.2 State Management

Use a simple, testable state-management approach.

Good options:

- Riverpod
- Bloc/Cubit
- ChangeNotifier with clear repository boundaries

For a code-generation LLM, **Riverpod or ChangeNotifier** is usually easiest to scaffold safely. The prompts below avoid requiring a specific state library unless the implementation prompt chooses one.

## 2.3 Persistence

Persistence should be abstracted behind repositories.

Suggested local storage choices:

- SQLite/Drift
- Isar
- Hive
- SharedPreferences only for very small preferences, not the whole data layer

The prompts below initially allow an in-memory repository for early tests, then move to a durable local repository once the domain models are stable.

## 2.4 Test Types

Use:

- Unit tests for domain logic.
- Repository tests for local data behavior.
- Widget tests for screens and navigation.
- Integration-style tests for flows where useful.

High-value test areas:

- Drill timing state machines.
- Character Creation cycle generation.
- Hands-Free announcement rules.
- Prompt validation.
- Import/export merge and duplicate skipping.
- Practice History logging threshold.
- Reset All Data and Reset Drill Defaults.

---

# Part 3 — Major Build Phases

## Phase 0 — Project Foundation

Set up the Flutter project, app shell, theme, navigation, test scaffolding, and static product constants.

Outputs:

- Running Flutter app.
- Bottom navigation: Practice, History, Settings.
- Practice home with drill cards and Tools card.
- Test infrastructure.
- Initial smoke/widget tests.

## Phase 1 — Domain Models and Local Repository Contracts

Define app models and repository interfaces before implementing complex features.

Outputs:

- Prompt categories.
- Prompt models.
- Drill IDs and drill settings models.
- Practice session model.
- Journal entry model.
- App preferences model.
- Repository interfaces.
- Unit tests for model serialization/equality/defaults.

## Phase 2 — Prompt System

Implement built-in seed prompt loading, custom prompt management, prompt selection, and on-device validation.

Outputs:

- Built-in local prompts.
- User custom prompts.
- Word bucket.
- Category filtering.
- Prompt validation.
- Prompt repository tests.
- Prompt generator UI wired into Tools.

## Phase 3 — Drill Timing Engine

Build reusable timer/session logic before adding every drill UI.

Outputs:

- Countdown segment model.
- Drill session controller/state machine.
- Pause/resume/stop behavior.
- Looping and finite-cycle support.
- Progress-ring calculation.
- Unit tests.

## Phase 4 — Guided Drills

Implement each drill as an integrated vertical slice.

Order:

1. Cat/Clock
2. Two-Character Scenes
3. A-to-C / Bad Idea / Initiation
4. Five Line Game Drill
5. Character Creation

Character Creation comes later because it has the most custom logic.

Outputs:

- Drill start screens.
- Configure screens.
- Session screens.
- Saved settings.
- Prompt integration.
- Timer integration.
- Tests per drill.

## Phase 5 — Hands-Free Mode and TTS

Add text-to-speech after drills are already functional visually.

Outputs:

- TTS abstraction.
- Global TTS settings.
- Hands-Free Mode per drill.
- Announcement policy.
- Tests using fake TTS service.
- UI controls.

## Phase 6 — Practice History and Journal

Implement local tracking and optional journal features.

Outputs:

- Practice session logging after 30 seconds.
- Stats dashboard.
- Recent 20 sessions.
- Journal create/edit/delete.
- Journal accessible from History and Tools.
- Tests.

## Phase 7 — Settings, Reset, Export/Import

Implement app settings, reset actions, JSON backup, import merge, duplicate skipping, and schema versioning.

Outputs:

- Appearance settings.
- TTS settings.
- Reset Drill Defaults.
- Reset All Data.
- Export JSON.
- Import JSON with merge/skip duplicates.
- Version/migration behavior.
- Tests.

## Phase 8 — Privacy, About, Support, Donate, Crash Reporting Shell

Implement static legal/support surfaces and optional crash-report user flow.

Outputs:

- Privacy/About page.
- Credits and unaffiliated disclaimer.
- Support email template.
- External Ko-fi link.
- Crash report prompt shell.
- Exclusion rules for user content.
- Tests where practical.

## Phase 9 — Accessibility, Tablet Layout, Polish, Final Integration

Finish non-functional requirements and final wiring.

Outputs:

- Accessibility labels.
- Large text support.
- Light/dark/system theme verification.
- Tablet-friendly layout refinements.
- Portrait phone lock.
- No prohibited permissions.
- Final acceptance test pass.

---

# Part 4 — First-Pass Chunk Breakdown

This is the first coarse breakdown.

1. Create Flutter project and test harness.
2. Add app shell and bottom navigation.
3. Build Practice home with drill cards and Tools card.
4. Define domain models and defaults.
5. Define repository interfaces.
6. Add in-memory repositories for early development.
7. Implement prompt categories and seed prompts.
8. Implement custom prompts with validation.
9. Build standalone Prompt Generator.
10. Build reusable timer engine.
11. Build Cat/Clock.
12. Build Two-Character Scenes.
13. Build A-to-C.
14. Build Five Line Game.
15. Build Character Creation.
16. Add TTS abstraction and Hands-Free Mode.
17. Add Practice History logging and stats.
18. Add Journal.
19. Add Settings.
20. Add export/import.
21. Add reset actions.
22. Add Privacy/About, Support, Donate.
23. Add crash-report prompt shell.
24. Add accessibility/tablet polish.
25. Final integration and acceptance testing.

This is directionally good, but several chunks are too large. We need another pass.

---

# Part 5 — Second-Pass Breakdown Into Safer Steps

## Foundation

1. Scaffold project, app constants, tests, linting.
2. Add app shell with theme and bottom navigation.
3. Add Practice home cards.
4. Add placeholder screens for History and Settings.
5. Add common UI components: app card, primary/secondary buttons, empty states.

## Domain and Data

6. Add core enums and IDs: drills, prompt categories, theme mode.
7. Add prompt models and seed prompt loader.
8. Add drill settings models with defaults.
9. Add history and journal models.
10. Add app preferences model.
11. Add repository interfaces.
12. Add in-memory repositories and tests.
13. Replace or back repositories with local persistence.

## Prompt System

14. Implement prompt picker logic.
15. Implement word bucket logic.
16. Implement custom prompt validation.
17. Implement custom prompt CRUD.
18. Build custom prompt management UI.
19. Build standalone Prompt Generator UI.
20. Add Prompt Generator auto-advance.

## Timer Engine

21. Implement countdown segment model.
22. Implement timer controller with start/tick/complete.
23. Add pause/resume.
24. Add looping segment sequences.
25. Add finite segment sequences.
26. Add circular progress calculation.
27. Add reusable drill session screen shell.

## Drills

28. Cat/Clock defaults and settings.
29. Cat/Clock session flow.
30. Two-Character Scenes defaults and settings.
31. Two-Character Scenes session flow.
32. A-to-C defaults and settings.
33. A-to-C session flow.
34. Five Line Game defaults and settings.
35. Five Line Game prompt-only flow.
36. Five Line Game optional auto-advance.
37. Character Creation cycle generator.
38. Character Creation settings.
39. Character Creation normal-mode session.
40. Character Creation hands-free prep hooks.

## TTS and Hands-Free

41. TTS service abstraction.
42. Global TTS settings model/UI.
43. Hands-Free toggle in drill configuration.
44. Announcement policy tests.
45. Add Hands-Free to Cat/Clock.
46. Add Hands-Free to Two-Character Scenes.
47. Add Hands-Free to A-to-C.
48. Add Hands-Free to Five Line Game.
49. Add Hands-Free to Character Creation.

## History and Journal

50. Add practice logging threshold service.
51. Wire logging into drills.
52. Build History stats calculations.
53. Build History UI with recent 20 sessions.
54. Build Journal CRUD.
55. Wire Journal from History.
56. Wire Journal from Tools.

## Settings and Backup

57. Build Settings sections.
58. Add Appearance settings.
59. Add Reset Drill Defaults.
60. Add Reset All Data.
61. Add export JSON serializer.
62. Add import JSON parser and schema version handling.
63. Add merge and duplicate skipping.
64. Wire Export/Import UI.

## Privacy and Release Surfaces

65. Build Privacy/About page.
66. Add Credits and unaffiliated disclaimer.
67. Add Support email template.
68. Add Ko-fi external link.
69. Add crash-report prompt shell and privacy exclusions.
70. Verify no forbidden permissions.

## Polish

71. Add accessibility labels.
72. Add dynamic type and contrast polish.
73. Add tablet layouts.
74. Lock phone portrait behavior.
75. Final acceptance tests and cleanup.

This is better, but still too many prompts for a first implementation pass. We can combine some UI placeholder steps while keeping complex logic small.

---

# Part 6 — Final Right-Sized Implementation Steps

The following sequence is right-sized for a code-generation LLM. It has enough steps to keep complexity controlled, but not so many that progress stalls.

Each step should be implemented with tests before moving to the next.

## Final Prompt Sequence Overview

1. Project scaffold, architecture, app shell, bottom navigation.
2. Practice home with drill/tool cards and placeholder routing.
3. Domain models, defaults, and repository interfaces.
4. In-memory repositories and seed prompt system.
5. Prompt picker, word bucket, and custom prompt validation.
6. Custom prompt CRUD and management UI.
7. Standalone Prompt Generator tool.
8. Reusable timer/session engine.
9. Reusable drill start/config/session shell.
10. Cat/Clock drill.
11. Two-Character Scenes drill.
12. A-to-C / Bad Idea / Initiation drill.
13. Five Line Game Drill.
14. Character Creation cycle logic.
15. Character Creation UI and normal-mode prompt generation.
16. Text-to-speech abstraction and global TTS settings.
17. Hands-Free Mode announcement policy.
18. Wire Hands-Free Mode into all drills.
19. Practice History logging and stats.
20. Practice Journal.
21. Standalone Timer tool.
22. Interactive Emotion Wheel tool.
23. Settings sections, appearance, reset drill defaults, reset all data.
24. JSON export/import with schema versioning, merge, and duplicate skipping.
25. Privacy/About, Credits, Support email, Ko-fi link.
26. Optional crash-report prompt shell and privacy exclusions.
27. Accessibility, tablet layout, phone portrait, permissions audit.
28. Final integration, acceptance tests, and cleanup.

This is the sequence used for the code-generation prompts below.

---

# Part 7 — Code-Generation LLM Prompts

Use these prompts sequentially. Each prompt assumes all previous prompts have been completed and tests are passing.

Each prompt is written for a code-generation LLM working inside the repository.

---

## Prompt 1 — Project Scaffold, Architecture, App Shell, Bottom Navigation [DONE]

```text
You are implementing Hermit-Prov, a free offline-first Flutter mobile app for solo long-form comedy improv practice.

Refer to the Hermit-Prov Developer Handoff Spec as the source of truth.

Task:
Set up the initial Flutter app architecture and a running app shell.

Requirements:
1. Create or update the Flutter project structure with clear folders for:
   - core
   - domain
   - data
   - features
   - ui
2. Add an app entry point with a Material app.
3. Add bottom navigation with exactly three tabs:
   - Practice
   - History
   - Settings
4. The app should launch directly into the Practice tab. No onboarding.
5. Add placeholder screens for Practice, History, and Settings.
6. Add a basic light/dark/system-compatible theme foundation, but do not build the full settings UI yet.
7. Keep the app English-only.
8. Do not add accounts, login, cloud sync, analytics, microphone permissions, notifications, ads, subscriptions, in-app purchases, or AI features.

Testing:
1. Add a widget test verifying the app launches.
2. Add a widget test verifying the bottom navigation contains Practice, History, and Settings.
3. Add a widget test verifying Practice is the initial tab.

Acceptance criteria:
- App runs.
- Bottom navigation works.
- Placeholder screens are reachable.
- Tests pass.
```

---

## Prompt 2 — Practice Home Cards and Placeholder Routing

```text
Continue implementing Hermit-Prov.

Previous state:
- Flutter app shell exists.
- Bottom navigation exists with Practice, History, Settings.
- Placeholder screens exist.

Task:
Build the Practice home screen as the Choose Your Drill screen.

Requirements:
1. Replace the Practice placeholder with a Practice Home screen.
2. Show clean cards for:
   - Cat/Clock
   - Character Creation
   - Two-Character Scenes
   - A-to-C / Bad Idea / Initiation
   - Five Line Game Drill
   - Tools
3. Each card must show:
   - Name
   - Short subtitle
4. Do not show saved settings on cards.
5. Tapping each drill card should navigate to a placeholder Drill Start screen for that drill.
6. Tapping Tools should navigate to a placeholder Tools screen.
7. Each placeholder Drill Start screen should show:
   - Drill name
   - Start button
   - Configure button
   - Info/help button placeholder
8. Start and Configure can be non-functional placeholders for now, but must be visible and testable.

Testing:
1. Widget test that all five drill cards and Tools card appear.
2. Widget test that tapping each card navigates to the correct placeholder screen.
3. Widget test that each Drill Start placeholder has Start, Configure, and info/help controls.

Acceptance criteria:
- Practice home matches the spec structure.
- Navigation is wired; no orphan screens.
- Tests pass.
```

---

## Prompt 3 — Domain Models, Defaults, and Repository Interfaces

```text
Continue implementing Hermit-Prov.

Previous state:
- App shell and Practice Home are working.
- Drill Start placeholders exist.

Task:
Add core domain models, default values, and repository interfaces.

Requirements:
1. Define enum/value types for:
   - DrillId: catClock, characterCreation, twoCharacterScenes, atoC, fiveLineGame
   - PromptCategory: objects, locations, relationships, occupations, emotions, activities
   - AppThemePreference: system, light, dark
2. Define the word bucket concept in code as all prompt categories combined. It does not need to be a persisted category.
3. Add models for:
   - BuiltInPrompt
   - CustomPrompt
   - DrillSettings
   - PracticeSession
   - JournalEntry
   - AppPreferences
4. Add default DrillSettings for each drill:
   - Cat/Clock: 3 min speaking, 30 sec regroup, two word prompts, loops until stopped
   - Character Creation: 2 characters, 60 sec segment, word bucket source
   - Two-Character Scenes: 90 sec scene, 30 sec regroup, word bucket source, loops until stopped
   - A-to-C / Bad Idea / Initiation: 30 sec interval, word bucket source, loops until stopped
   - Five Line Game Drill: prompt only, auto-advance off, optional intervals 30/60/90, word bucket source
5. Add repository interfaces for:
   - PromptRepository
   - DrillSettingsRepository
   - PracticeHistoryRepository
   - JournalRepository
   - AppPreferencesRepository
6. Keep these interfaces independent from any specific database package.

Testing:
1. Unit tests for default settings for every drill.
2. Unit tests for allowed Character Creation segment durations: 60, 90, 120 seconds.
3. Unit tests for A-to-C allowed intervals: 15, 30, 45, 60 seconds.
4. Unit tests for Five Line Game auto-advance allowed intervals: 30, 60, 90 seconds.
5. Unit test that the word bucket expands to all six prompt categories.

Acceptance criteria:
- Models and interfaces compile.
- Defaults match the handoff spec.
- Tests pass.
```

---

## Prompt 4 — In-Memory Repositories and Seed Prompt System

```text
Continue implementing Hermit-Prov.

Previous state:
- Domain models and repository interfaces exist.
- Drill defaults are tested.

Task:
Implement in-memory repositories and a simple local seed prompt system.

Requirements:
1. Implement in-memory versions of:
   - PromptRepository
   - DrillSettingsRepository
   - PracticeHistoryRepository
   - JournalRepository
   - AppPreferencesRepository
2. These are acceptable for now and will later be replaceable with durable local persistence.
3. Add a seed prompt source with a small placeholder set for each category:
   - Objects
   - Locations
   - Relationships
   - Occupations
   - Emotions
   - Activities
4. The seed prompt source must be clearly marked as placeholder content. The final robust human-curated lists are a separate content task.
5. Built-in prompts should be read-only through the repository.
6. Custom prompts should be stored separately from built-in prompts.
7. Do not implement prompt validation yet.

Testing:
1. Repository test that built-in prompts load for all six categories.
2. Repository test that custom prompts can be added separately from built-in prompts.
3. Repository test that built-in prompts cannot be edited or deleted.
4. Repository test that DrillSettingsRepository returns defaults before any saved settings exist.
5. Repository test that saving drill settings updates the returned settings.

Acceptance criteria:
- App still runs.
- In-memory repositories are wired into the app through dependency injection or a simple provider pattern.
- Tests pass.
```

---

## Prompt 5 — Prompt Picker, Word Bucket, and Custom Prompt Validation

```text
Continue implementing Hermit-Prov.

Previous state:
- In-memory repositories exist.
- Placeholder built-in prompts exist.
- Custom prompts can be stored but are not yet validated.

Task:
Implement prompt selection logic and custom prompt validation.

Requirements:
1. Add a PromptPicker service that can:
   - Pick a random prompt from one category.
   - Pick a random prompt from multiple categories.
   - Pick a random prompt from the word bucket.
   - Include both built-in and custom prompts automatically.
2. Do not add built-in/custom-only filters. They are not part of v1.
3. Implement on-device CustomPromptValidator.
4. Validator must broadly block slurs using a local blocklist/ruleset.
5. Validator must narrowly block clearly explicit/graphic sexual content.
6. Validator must allow non-graphic adult relationship/dating prompts such as bad date, affair, crush, flirting, awkward hookup, divorce.
7. When validation fails, expose only a simple generic error. Do not expose the reason.
8. Rejected prompts must not be saved or logged.
9. No network calls.

Testing:
1. Unit tests for picking from a single category.
2. Unit tests for picking from multiple categories.
3. Unit tests for word bucket picking across all categories.
4. Unit test that custom and built-in prompts are both eligible.
5. Validator tests for broad slur blocking.
6. Validator tests for narrow explicit sexual-content blocking.
7. Validator tests that allowed adult-life prompts pass.
8. Repository test that rejected prompts are not saved.

Acceptance criteria:
- PromptPicker and CustomPromptValidator are tested.
- All validation is local-only.
- Tests pass.
```

---

## Prompt 6 — Custom Prompt CRUD and Management UI

```text
Continue implementing Hermit-Prov.

Previous state:
- PromptPicker exists.
- CustomPromptValidator exists.
- In-memory prompt repository exists.

Task:
Build a simple Custom Prompt management UI and wire it into the app.

Requirements:
1. Add a Custom Prompts screen reachable from the Tools screen or Prompt Generator screen.
2. Users can:
   - View custom prompts grouped or filterable by category.
   - Add a custom prompt to one of the six existing categories.
   - Edit a custom prompt.
   - Delete a custom prompt.
3. Users cannot edit, delete, or disable built-in prompts.
4. On save, run CustomPromptValidator.
5. If validation fails, show a simple generic error message:
   - “This prompt can’t be saved because it violates content rules.”
6. Do not log blocked attempts.
7. Keep UI simple and accessible.

Testing:
1. Widget test that Custom Prompts screen is reachable.
2. Widget test that a valid custom prompt can be added.
3. Widget test that a custom prompt can be edited.
4. Widget test that a custom prompt can be deleted.
5. Widget test that a blocked prompt shows the generic error and is not listed afterward.
6. Widget test that built-in prompts are not shown as editable custom prompts.

Acceptance criteria:
- Custom prompt management is usable from the app.
- No orphan CRUD logic.
- Tests pass.
```

---

## Prompt 7 — Standalone Prompt Generator Tool

```text
Continue implementing Hermit-Prov.

Previous state:
- Tools screen exists as placeholder.
- PromptPicker exists.
- Custom prompts can be managed.

Task:
Implement the standalone Prompt Generator tool.

Requirements:
1. Tools screen should list:
   - Prompt Generator
   - Timer placeholder
   - Emotion Wheel placeholder
   - Practice Journal placeholder
2. Prompt Generator screen should allow users to:
   - Select any combination of the six prompt categories.
   - Select the word bucket.
   - Tap New Prompt manually.
   - See the generated prompt clearly.
3. Add optional auto-advance toggle.
4. Auto-advance intervals:
   - 15 seconds
   - 30 seconds
   - 45 seconds
   - 60 seconds
5. When auto-advance is enabled, the prompt should refresh on the selected interval.
6. Auto-advance should stop when leaving the screen.
7. Custom prompts and built-in prompts should be mixed automatically.

Testing:
1. Widget test that Tools screen shows all four tools.
2. Widget test that Prompt Generator is reachable.
3. Widget test that New Prompt displays a prompt.
4. Widget test that category selection affects the eligible prompt pool.
5. Unit or widget test for auto-advance using fake timers if available.
6. Test that auto-advance is cancelled/disposed when leaving the screen.

Acceptance criteria:
- Prompt Generator is fully wired into Tools.
- No timer leaks.
- Tests pass.
```

---

## Prompt 8 — Reusable Timer and Session Engine

```text
Continue implementing Hermit-Prov.

Previous state:
- Prompt system and standalone Prompt Generator work.

Task:
Implement a reusable timer/session engine for drill flows.

Requirements:
1. Create domain models for timer segments:
   - segment id/type
   - duration
   - optional prompt payload
   - optional display label
2. Create a DrillSessionController or equivalent state machine that supports:
   - Start
   - Tick
   - Pause
   - Resume
   - Stop request
   - Segment complete
   - Session complete for finite flows
   - Looping flows for drills that repeat until stopped
3. Timer logic should be testable without real time by allowing manual ticks or a fake clock.
4. Support current segment remaining time.
5. Support elapsed session time.
6. Support circular progress value for the current rep/cycle or current finite segment sequence.
7. Pause must freeze timer and prompt/segment changes.
8. No UI yet except any minimal test harness needed.

Testing:
1. Unit test countdown decreases with ticks.
2. Unit test segment completion advances to next segment.
3. Unit test looping sequence restarts after final segment.
4. Unit test finite sequence completes after final segment.
5. Unit test pause freezes time and segment changes.
6. Unit test resume continues correctly.
7. Unit test progress calculation.

Acceptance criteria:
- Timer/session engine is reusable and independent of Flutter widgets.
- Tests pass.
```

---

## Prompt 9 — Reusable Drill Start, Configure, and Session Shell

```text
Continue implementing Hermit-Prov.

Previous state:
- Timer/session engine exists and is tested.
- Drill Start placeholders exist.
- Drill settings repository exists.

Task:
Replace placeholders with reusable drill scaffolding.

Requirements:
1. Build a reusable Drill Start screen pattern:
   - Drill name
   - Subtitle/short description
   - Start button
   - Configure button
   - Info/help button
2. Build a reusable Configure screen pattern that can be customized per drill.
3. Build a reusable active Drill Session shell with:
   - Large countdown timer when applicable
   - Circular progress ring
   - Prompt/label display area
   - Pause/Resume button
   - Stop/End button
4. Stop/End must show a confirmation dialog before ending.
5. When ended, return to that drill’s Start screen.
6. Start should use saved drill settings.
7. Configure should update saved drill settings when the user starts from the configuration screen.
8. Do not implement full drill behavior yet; wire at least one simple fake drill flow to prove the shell works.

Testing:
1. Widget test that Drill Start screen shows Start, Configure, and info/help.
2. Widget test that Configure can update a simple saved setting.
3. Widget test that Start launches the session shell.
4. Widget test that Pause changes to Resume and freezes displayed timer when using fake time/manual tick.
5. Widget test that Stop/End shows confirmation.
6. Widget test that confirming Stop returns to Drill Start.

Acceptance criteria:
- Common drill UI is wired and testable.
- Future drills can plug into this shell.
- Tests pass.
```

---

## Prompt 10 — Cat/Clock Drill

```text
Continue implementing Hermit-Prov.

Previous state:
- Reusable drill shell exists.
- PromptPicker exists.
- Drill settings persist.

Task:
Implement the Cat/Clock guided drill.

Requirements:
1. Default behavior:
   - Generate two prompts at the start of each rep.
   - Speaking segment defaults to 3 minutes.
   - Regroup segment defaults to 30 seconds.
   - Repeat automatically until the user stops.
2. Default prompt setup:
   - Prompt 1 from word bucket.
   - Prompt 2 from word bucket.
3. Configure screen should allow:
   - Speaking duration configuration.
   - Regroup duration configuration.
   - Prompt 1 category source.
   - Prompt 2 category source.
   - Hands-Free toggle placeholder if the shared model already supports it, but do not implement TTS yet.
4. The active session screen should show:
   - Both prompts during speaking.
   - Countdown/progress.
   - No extra state labels unless necessary.
   - Regroup countdown during regroup.
5. Regroup should be visually distinct enough to know a regroup is happening, but do not add noisy instructional copy.
6. Stop confirmation must work.
7. Pause/resume must work.

Testing:
1. Unit test Cat/Clock sequence creates speaking + regroup segments.
2. Unit test sequence loops until stopped.
3. Unit test prompts regenerate for each new speaking rep.
4. Widget test Start launches Cat/Clock with two prompts.
5. Widget test Configure saves changed speaking/regroup durations.
6. Widget test Pause/Resume works.
7. Widget test Stop confirmation returns to Cat/Clock Start screen.

Acceptance criteria:
- Cat/Clock is usable end-to-end.
- Settings persist locally.
- Tests pass.
```

---

## Prompt 11 — Two-Character Scenes Drill

```text
Continue implementing Hermit-Prov.

Previous state:
- Cat/Clock is implemented.
- Reusable drill shell and timer engine exist.

Task:
Implement the Two-Character Scenes guided drill.

Requirements:
1. Default behavior:
   - Generate one prompt.
   - Run 90-second scene timer.
   - Run 30-second regroup timer.
   - Generate new prompt.
   - Repeat until stopped.
2. Configure screen should allow:
   - Scene duration.
   - Regroup duration.
   - Prompt category source, default word bucket.
   - Hands-Free toggle placeholder if available, no TTS yet.
3. Active session should show only:
   - Prompt during scene segment.
   - Timer/progress.
   - Pause/Resume.
   - Stop/End.
4. The app should not display which character is speaking.
5. Regroup should not generate a prompt.

Testing:
1. Unit test Two-Character sequence: prompt scene + regroup loop.
2. Unit test prompt regenerates after regroup.
3. Widget test Start launches with one prompt.
4. Widget test no character speaker labels are present.
5. Widget test Configure saves timer/category settings.
6. Widget test Stop confirmation works.

Acceptance criteria:
- Two-Character Scenes is usable end-to-end.
- Tests pass.
```

---

## Prompt 12 — A-to-C / Bad Idea / Initiation Drill

```text
Continue implementing Hermit-Prov.

Previous state:
- Cat/Clock and Two-Character Scenes are implemented.

Task:
Implement the A-to-C / Bad Idea / Initiation drill as one combined drill.

Requirements:
1. This is one drill with the full name “A-to-C / Bad Idea / Initiation.”
2. Default behavior:
   - Show one prompt.
   - Change prompt every 30 seconds.
   - Repeat rapid-fire until stopped.
3. Configure screen should allow interval selection:
   - 15 seconds
   - 30 seconds
   - 45 seconds
   - 60 seconds
4. Configure screen should allow prompt category source, default word bucket.
5. Active session should show:
   - Current prompt.
   - Countdown/progress for current interval.
   - Pause/Resume.
   - Stop/End.
6. No regroup segment.

Testing:
1. Unit test default interval is 30 seconds.
2. Unit test only allowed intervals are 15/30/45/60.
3. Unit test prompt changes each interval.
4. Unit test flow loops until stopped.
5. Widget test Start launches with one prompt.
6. Widget test Configure saves interval/category settings.
7. Widget test Pause/Resume freezes prompt changes.

Acceptance criteria:
- A-to-C / Bad Idea / Initiation is usable end-to-end.
- Tests pass.
```

---

## Prompt 13 — Five Line Game Drill

```text
Continue implementing Hermit-Prov.

Previous state:
- Cat/Clock, Two-Character Scenes, and A-to-C are implemented.

Task:
Implement the Five Line Game Drill.

Requirements:
1. Default behavior:
   - Show one prompt.
   - No timer by default.
   - User taps New Prompt for another rep.
2. The app must not display:
   - Line 1/2/3/4/5 labels.
   - Initiation/response/heightening/turn/button labels.
3. Configure screen should allow:
   - Prompt category source, default word bucket.
   - Optional auto-advance toggle.
   - Auto-advance interval options: 30, 60, 90 seconds.
4. If auto-advance is on:
   - Show countdown/progress.
   - Generate a new prompt after each interval.
5. If auto-advance is off:
   - Show prompt and New Prompt button.
   - No timer required.
6. Pause/Resume only applies when auto-advance is on.
7. Stop/End should return to Start screen with confirmation if a session is active.

Testing:
1. Widget test default screen shows prompt and New Prompt button, no timer.
2. Widget test New Prompt changes the prompt.
3. Widget test no line labels or structural labels appear.
4. Unit/widget test auto-advance changes prompts at selected interval.
5. Widget test Configure saves category and auto-advance settings.
6. Widget test Pause/Resume works when auto-advance is on.

Acceptance criteria:
- Five Line Game Drill is usable end-to-end.
- Tests pass.
```

---

## Prompt 14 — Character Creation Cycle Logic

```text
Continue implementing Hermit-Prov.

Previous state:
- Four drills are implemented.
- Timer/session engine exists.

Task:
Implement Character Creation domain logic before building the full UI.

Requirements:
1. Add CharacterCreationCycleBuilder or equivalent.
2. Default number of characters: 2.
3. Configurable number of characters up to approximately 5. Use exactly max 5 unless there is already a project constant.
4. Segment duration options only:
   - 60 seconds
   - 90 seconds
   - 120 seconds
5. Each character has two passes:
   - First pass
   - Return pass
6. Cycle order for 2 characters:
   - Character 1
   - Character 2
   - Return to Character 1
   - Return to Character 2
7. Cycle order for 5 characters:
   - Character 1
   - Character 2
   - Character 3
   - Character 4
   - Character 5
   - Return to Character 1
   - Return to Character 2
   - Return to Character 3
   - Return to Character 4
   - Return to Character 5
8. Total duration equals characters × 2 × segment duration.
9. The session ends when the cycle completes. It does not loop indefinitely.
10. Add metadata to segments indicating first pass vs return pass.

Testing:
1. Unit test default 2-character cycle.
2. Unit test 5-character cycle.
3. Unit test total duration calculation.
4. Unit test allowed segment durations.
5. Unit test invalid character counts are rejected or clamped according to your chosen approach.
6. Unit test return-pass labels.

Acceptance criteria:
- Character Creation cycle logic is fully tested before UI.
- Tests pass.
```

---

## Prompt 15 — Character Creation UI and Normal-Mode Prompt Generation

```text
Continue implementing Hermit-Prov.

Previous state:
- Character Creation cycle logic exists and is tested.
- Other drills are implemented.

Task:
Implement the Character Creation drill UI in normal visual mode.

Requirements:
1. Drill Start screen should use shared drill start pattern.
2. Configure screen should allow:
   - Number of characters: 1 to 5, default 2.
   - Segment duration: 60, 90, or 120 seconds, default 60.
   - Prompt category source, default word bucket.
   - Hands-Free toggle placeholder if available, but full TTS comes later.
3. Active session should display:
   - “Character N” on first pass.
   - “Return to Character N” on return pass.
   - Countdown/progress.
   - Pause/Resume.
   - Stop/End.
4. In normal mode, prompt generation is manual and optional.
5. During each first pass only, show a Generate Prompt button.
6. If tapped, generate and display one prompt for that character during that first pass.
7. Do not show Generate Prompt on return passes.
8. Do not show the original prompt on return passes.
9. Do not provide a Character List or review button. Remembering is part of the drill.
10. The session ends after the full cycle and returns to the Start screen.

Testing:
1. Widget test default 2-character setup launches Character 1.
2. Widget test Generate Prompt appears only on first passes.
3. Widget test Generate Prompt displays a prompt during first pass.
4. Widget test return pass shows “Return to Character N” and no prompt.
5. Widget test there is no Character List/review button.
6. Widget test session completes after final return pass.
7. Widget test Configure saves character count, segment duration, and prompt categories.

Acceptance criteria:
- Character Creation normal mode is usable end-to-end.
- Tests pass.
```

---

## Prompt 16 — Text-to-Speech Abstraction and Global TTS Settings

```text
Continue implementing Hermit-Prov.

Previous state:
- All five drills are visually implemented.
- Hands-Free toggle may exist as placeholder but does not perform TTS yet.

Task:
Add a testable text-to-speech abstraction and global TTS settings.

Requirements:
1. Create a TtsService interface with methods such as:
   - speak(text)
   - stop()
   - getAvailableVoices() if supported by chosen package
   - setVoice/settings if supported
2. Create a fake TTS service for tests.
3. Add global TTS settings to AppPreferences:
   - voice
   - speaking rate
4. Build Settings > Text-to-Speech UI that allows configuring:
   - voice where available
   - speaking rate
5. TTS settings apply globally across the app.
6. Do not make Hands-Free Mode an app-wide default.
7. Do not request microphone or speech-recognition permissions.
8. Do not add recording.

Testing:
1. Unit test fake TTS captures spoken text.
2. Repository test that TTS settings persist.
3. Widget test Settings > Text-to-Speech is reachable.
4. Widget test changing speaking rate saves preference.
5. Permissions/configuration audit test if practical, or static check/documentation that no microphone permission is added.

Acceptance criteria:
- TTS service is abstracted and testable.
- Global TTS settings exist.
- Tests pass.
```

---

## Prompt 17 — Hands-Free Announcement Policy

```text
Continue implementing Hermit-Prov.

Previous state:
- TTS service abstraction exists.
- Global TTS settings exist.
- All five drills are visually implemented.

Task:
Implement the domain-level Hands-Free announcement policy before wiring it to UI.

Requirements:
1. Create a HandsFreeAnnouncementPolicy service.
2. For non-character prompt segments:
   - Read the prompt aloud when it appears.
   - This replaces any “begin” announcement.
3. For segments longer than 30 seconds:
   - Announce “30 seconds.”
   - Announce “10 seconds.”
   - Announce “time.”
4. For exactly 30-second segments:
   - No timer announcements.
   - If there is a prompt, read only the prompt.
   - If there is no prompt, stay silent.
5. Regroup segments stay silent.
6. For Character Creation hands-free first passes:
   - Automatically generate a prompt.
   - Announce “Character N: prompt.”
7. For Character Creation return passes:
   - Announce only “Character N.”
   - Do not say “Return to Character N.”
   - Do not display or speak the original prompt.
8. When paused:
   - No announcements.
9. On resume:
   - Continue announcement behavior from that point forward.

Testing:
1. Unit tests for prompt reading replacing “begin.”
2. Unit tests for >30 second timer announcements.
3. Unit tests for exactly 30-second segment silence except prompt.
4. Unit tests for regroup silence.
5. Unit tests for A-to-C default 30-second behavior.
6. Unit tests for Character Creation first-pass announcement.
7. Unit tests for Character Creation return-pass announcement.
8. Unit tests that paused state suppresses announcements.

Acceptance criteria:
- Announcement policy is fully tested without real TTS.
- Tests pass.
```

---

## Prompt 18 — Wire Hands-Free Mode Into All Drills

```text
Continue implementing Hermit-Prov.

Previous state:
- TTS service exists.
- HandsFreeAnnouncementPolicy is tested.
- All five drills are visually implemented.

Task:
Wire Hands-Free Mode into every drill.

Requirements:
1. Each drill Configure screen should allow Hands-Free Mode to be toggled for that drill/session configuration.
2. Hands-Free Mode is off by default.
3. Hands-Free Mode should use the global TTS settings.
4. Cat/Clock:
   - Read both prompts together at the start of each speaking rep.
   - Stay silent during regroup.
   - Use timer announcements for 3-minute speaking segments.
5. Two-Character Scenes:
   - Read prompt when scene starts.
   - Use timer announcements for 90-second scene segments.
   - Stay silent during regroup.
6. A-to-C:
   - Read each new prompt aloud.
   - Default 30-second interval has no timer announcements.
7. Five Line Game:
   - Read prompt when shown.
   - If auto-advance is on, read each new prompt.
   - Timer announcements only if interval is longer than 30 seconds.
8. Character Creation:
   - Automatically generate prompts on first passes.
   - Display generated prompt during first pass.
   - Speak “Character N: prompt.”
   - On return pass, speak only “Character N.”
   - Do not display the original prompt on return pass.
9. Pause must suppress announcements.
10. Stop must stop TTS if speaking.

Testing:
1. Widget/unit tests with fake TTS for each drill’s hands-free behavior.
2. Test Hands-Free default is off.
3. Test prompt reading in Cat/Clock.
4. Test A-to-C 30-second prompt reading with no timer announcements.
5. Test Character Creation automatic prompt generation in Hands-Free Mode.
6. Test pause suppresses announcements.
7. Test stop calls TTS stop.

Acceptance criteria:
- Hands-Free Mode works across all drills.
- Tests pass.
```

---

## Prompt 19 — Practice History Logging and Stats

```text
Continue implementing Hermit-Prov.

Previous state:
- All drills and Hands-Free Mode are implemented.
- PracticeHistoryRepository exists.

Task:
Implement Practice History logging and dashboard stats.

Requirements:
1. A drill session should be logged if the user spends at least 30 seconds in a drill.
2. Sessions under 30 seconds should not be logged.
3. Logged session fields:
   - Drill name/id
   - Date/time
   - Duration
4. Do not store prompts used.
5. Do not store settings used.
6. Logging should be silent. Do not show “Session saved.”
7. Practice day/streak counts only completing at least one drill session of at least 30 seconds.
8. Standalone tool usage does not count toward streaks.
9. Journal entries do not count toward streaks.
10. History dashboard should show:
   - Total practice time
   - Sessions completed
   - Current streak
   - Longest streak
   - Breakdown by drill
11. Recent sessions list should show the most recent 20 sessions.
12. Keep v1 simple:
   - No date filters.
   - No drill filters.
   - No individual session deletion.

Testing:
1. Unit test logging threshold under 30 seconds does not log.
2. Unit test 30 seconds or more logs.
3. Unit test total practice time.
4. Unit test sessions completed.
5. Unit test current streak.
6. Unit test longest streak.
7. Unit test breakdown by drill.
8. Widget test History tab shows Practice Stats section/button.
9. Widget test recent list shows only most recent 20 sessions.
10. Widget test no individual delete control is present.

Acceptance criteria:
- Drill sessions log silently and correctly.
- History dashboard works.
- Tests pass.
```

---

## Prompt 20 — Practice Journal

```text
Continue implementing Hermit-Prov.

Previous state:
- Practice History exists.
- JournalRepository interface exists.

Task:
Implement the Practice Journal.

Requirements:
1. Journal must be accessible from:
   - History tab
   - Tools section
2. History tab should have separate sub-sections/buttons for:
   - Practice Stats
   - Journal
3. Journal entries should have:
   - Date/createdAt
   - UpdatedAt
   - Optional drill name tag
   - Body text
4. Users can:
   - Create entry
   - Edit entry
   - Delete entry
5. Journal list should show newest-first.
6. Each list item should show:
   - Date
   - Optional drill tag
   - Short preview
7. Keep v1 simple:
   - No search.
   - No filters.
   - No required link to a specific practice session.
8. Creating a journal entry does not count toward practice streaks.

Testing:
1. Widget test Journal is reachable from History.
2. Widget test Journal is reachable from Tools.
3. Widget test create entry.
4. Widget test edit entry.
5. Widget test delete entry.
6. Unit/widget test entries sort newest-first.
7. Unit test journal entries do not affect streak calculations.

Acceptance criteria:
- Journal is fully usable.
- Tests pass.
```

---

## Prompt 21 — Standalone Timer Tool

```text
Continue implementing Hermit-Prov.

Previous state:
- Tools screen exists.
- Prompt Generator and Journal are wired.
- Reusable timer engine exists.

Task:
Implement the standalone Timer tool.

Requirements:
1. Timer tool should be reachable from Tools.
2. Support simple configurable countdown timer.
3. Support interval cycle mode:
   - Work time
   - Regroup/rest time
   - Repeating cycle
4. Use shared timer components where appropriate.
5. Include:
   - Start
   - Pause/Resume
   - Stop/Reset
6. Tool usage should not count toward Practice History or streaks.
7. Keep UI simple.

Testing:
1. Widget test Timer tool is reachable.
2. Unit/widget test simple countdown completes.
3. Unit/widget test interval cycle alternates work/rest.
4. Widget test pause/resume.
5. Widget test stop/reset.
6. Unit test Timer tool usage does not create practice history records.

Acceptance criteria:
- Timer tool works independently.
- Tests pass.
```

---

## Prompt 22 — Interactive Emotion Wheel Tool

```text
Continue implementing Hermit-Prov.

Previous state:
- Tools section includes Prompt Generator, Timer, and Journal.

Task:
Implement the interactive Emotion Wheel tool.

Requirements:
1. Emotion Wheel should be reachable from Tools.
2. It should be interactive, not a static image.
3. It should support broad emotion categories and drill-down into more specific emotions.
4. Users can select an emotion as a prompt within the Emotion Wheel tool.
5. Selected emotions stay inside the Emotion Wheel tool in v1.
6. Do not send selected emotions into drills.
7. Use original placeholder taxonomy/content for now.
8. Do not copy protected images or protected text from referenced emotion wheel articles.
9. Keep UI accessible and usable with screen readers.

Testing:
1. Widget test Emotion Wheel is reachable from Tools.
2. Widget test broad emotion categories appear.
3. Widget test tapping a broad emotion reveals more specific emotions.
4. Widget test selecting an emotion displays it as selected.
5. Widget test there is no “send to drill” action.
6. Accessibility-oriented widget test for labels if practical.

Acceptance criteria:
- Emotion Wheel is interactive and self-contained.
- Tests pass.
```

---

## Prompt 23 — Settings Sections, Appearance, Reset Drill Defaults, Reset All Data

```text
Continue implementing Hermit-Prov.

Previous state:
- Main app features and tools are implemented.
- Settings exists but may still be partly placeholder.

Task:
Build the main Settings sections and reset actions.

Requirements:
1. Settings should be grouped into sections:
   - Appearance
   - Text-to-Speech
   - Drill Defaults
   - Data Backup placeholder
   - Privacy/About placeholder
   - Support/Donate placeholder
2. Appearance settings:
   - System
   - Light
   - Dark
   - Default System
3. Appearance preference should persist locally.
4. Reset Drill Defaults:
   - Restores all drill timings, prompt categories, and drill-specific options to built-in defaults.
   - Does not delete custom prompts.
   - Does not delete journal entries.
   - Does not delete practice history.
   - Requires standard confirmation dialog.
5. Reset All Data:
   - Deletes custom prompts.
   - Deletes journal entries.
   - Deletes practice history.
   - Resets saved drill settings.
   - Resets theme preference.
   - Resets TTS settings.
   - Requires standard confirmation dialog.
6. No need for typing RESET.

Testing:
1. Widget test Settings sections appear.
2. Widget test theme preference can be changed and saved.
3. Unit/widget test Reset Drill Defaults restores drill defaults only.
4. Unit/widget test Reset Drill Defaults preserves custom prompts, journal, and history.
5. Unit/widget test Reset All Data clears expected data.
6. Widget test both reset actions show confirmation dialogs.

Acceptance criteria:
- Settings is functionally useful.
- Reset behavior is safe and tested.
- Tests pass.
```

---

## Prompt 24 — JSON Export/Import With Schema Versioning, Merge, and Duplicate Skipping

```text
Continue implementing Hermit-Prov.

Previous state:
- Settings has Data Backup placeholder.
- Local repositories exist for prompts, journal, history, drill settings, and preferences.

Task:
Implement JSON export/import backup.

Requirements:
1. Data Backup section should include:
   - Export Data
   - Import Data
   - Local-only backup warning
2. Backup warning near Export/Import:
   - “Data stays on this device unless you export it. Uninstalling the app or switching devices may delete your local data.”
3. Export should generate one JSON backup file on demand and use the platform share/save flow where available.
4. JSON export should include:
   - schemaVersion
   - appVersion/export metadata
   - custom prompts
   - journal entries
   - practice history
   - saved drill settings
   - theme preference
   - text-to-speech settings
   - other safe app preferences
5. JSON export should exclude:
   - current app state
   - pending crash report state
   - transient runtime data
   - blocked prompt attempts
6. Import should:
   - Accept a Hermit-Prov JSON file.
   - Merge imported data with existing local data.
   - Skip duplicates automatically.
   - Not show a review screen in v1.
7. Schema versioning:
   - Include a human-readable schema version.
   - Reject unsupported future schema version with clear message.
   - Migrate older supported schema versions into current local schema.
8. Document duplicate rules in code comments or developer docs.
9. Data Backup should exist only in Settings, not on History or Journal screens.

Testing:
1. Unit test export includes expected data.
2. Unit test export excludes transient/current state.
3. Unit test import merges data.
4. Unit test import skips duplicate custom prompts.
5. Unit test import skips duplicate journal entries.
6. Unit test import skips duplicate practice sessions.
7. Unit test unsupported future schema version is rejected with specified message.
8. Unit test older supported schema version migrates.
9. Widget test Export and Import controls are visible only in Settings.
10. Widget test backup warning appears.

Acceptance criteria:
- Backup/restore works locally.
- Schema version behavior is documented and tested.
- Tests pass.
```

---

## Prompt 25 — Privacy/About, Credits, Support Email, Ko-fi Link

```text
Continue implementing Hermit-Prov.

Previous state:
- Settings sections exist.
- Data Backup exists.

Task:
Implement Privacy/About, Credits, Support, and Donate surfaces.

Requirements:
1. Privacy/About page should be reachable from Settings.
2. Privacy/About must clearly state:
   - No account.
   - No login.
   - No cloud sync.
   - Fully usable offline after installation.
   - User data stays on-device.
   - No audio recording.
   - No microphone permission.
   - No speech recognition.
   - No prompts, journal entries, or practice history are sent anywhere by default.
   - Optional crash reports are user-triggered only after a crash.
   - Crash reports include technical crash details and app state, but exclude custom prompts and journal entries.
   - Data is local-only; users should export before deleting the app or switching devices.
3. Include visible No Recording assurance:
   - “Hermit-Prov does not record audio and does not request microphone permission.”
4. Credits section should include links to inspiration sources specified in the handoff spec.
5. Credits must explicitly state Hermit-Prov is unofficial and unaffiliated with all inspiration sources.
6. Support/Feedback link should open an email to the developer.
7. Support email template should include:
   - App version
   - Device OS
   - Short prompt for issue
8. Support email must not automatically include:
   - Custom prompts
   - Journal entries
   - Practice history
9. Donate link should be low-key in Settings/About and open external Ko-fi page.
10. No in-app purchases.
11. No donation prompts after sessions.

Testing:
1. Widget test Privacy/About is reachable.
2. Widget test No Recording assurance appears.
3. Widget test unaffiliated disclaimer appears.
4. Widget test Support link exists.
5. Unit/widget test support email template excludes user-created local data.
6. Widget test Ko-fi link exists only in Settings/About area.
7. Widget test there is no donation prompt after completing a drill session.

Acceptance criteria:
- Privacy/About and support surfaces match spec.
- Tests pass.
```

---

## Prompt 26 — Optional Crash-Report Prompt Shell and Privacy Exclusions

```text
Continue implementing Hermit-Prov.

Previous state:
- Privacy/About page exists.
- Settings and support surfaces exist.

Task:
Implement the optional crash-report prompt shell and data sanitization logic.

Requirements:
1. Crash reports must never be automatic.
2. After a crash, the user may be prompted with:
   - Send Report
   - Don’t Send
3. If real crash-report provider integration is not configured yet, implement a provider abstraction and a fake/no-op provider.
4. Crash prompt should include privacy note:
   - “Includes technical crash details and app state, but not your custom prompts or journal entries.”
5. Crash report payload may include:
   - Technical crash details
   - Device OS/version
   - App version
   - Recent app state such as active drill, timer value, settings, and screen name
6. Crash report payload must exclude:
   - Custom prompts
   - Journal entries
   - Audio data
   - Microphone data
   - User-created content
7. Do not persist a crash-report opt-in preference.
8. Privacy/About should be linkable from the crash prompt.

Testing:
1. Unit test crash payload sanitizer excludes custom prompts.
2. Unit test crash payload sanitizer excludes journal entries.
3. Unit test crash payload includes allowed app state.
4. Widget test crash prompt shows Send Report and Don’t Send.
5. Widget test crash prompt shows privacy note.
6. Widget test Don’t Send does not call provider.
7. Widget test Send Report calls provider with sanitized payload.
8. Unit test no persistent crash-report preference is created.

Acceptance criteria:
- Crash-report flow is optional, sanitized, and testable.
- Tests pass.
```

---

## Prompt 27 — Accessibility, Tablet Layout, Phone Portrait, Permissions Audit

```text
Continue implementing Hermit-Prov.

Previous state:
- All main features are implemented.

Task:
Polish non-functional requirements: accessibility, tablet layouts, portrait behavior, and permission audit.

Requirements:
1. Accessibility:
   - Add screen reader labels for major buttons, prompts, timers, progress indicators, and navigation.
   - Ensure prompt text and timer text support large text/dynamic type.
   - Ensure sufficient contrast in light and dark themes.
   - Ensure reduced-motion behavior where applicable.
   - Ensure touch targets are comfortably sized.
   - Ensure timer/progress information is available to screen readers.
2. Tablet support:
   - Add tablet-friendly responsive layouts.
   - Do not simply scale phone UI.
   - Use wider cards, generous spacing, centered drill controls, and split-pane layouts where appropriate for History/Journal.
3. Orientation:
   - Phones should be portrait only.
   - Tablets should remain tablet-friendly; follow platform best practice while preserving the spec.
4. Permission audit:
   - Confirm no microphone permission.
   - Confirm no speech-recognition permission.
   - Confirm no notification permission.
   - Confirm no recording permission.
   - Network access should only be needed for user-triggered external actions such as crash report, support email, Ko-fi, and external links.
5. Do not add push notifications or local reminder notifications.

Testing:
1. Widget tests for key semantic labels.
2. Widget tests with larger text scale for major screens.
3. Golden or layout tests for narrow phone and wider tablet widths if available.
4. Static permission/configuration test or documented assertion that forbidden permissions are absent.
5. Regression test that app still launches and core navigation works.

Acceptance criteria:
- App is accessible enough for v1.
- Tablet layouts are intentionally handled.
- Forbidden permissions are absent.
- Tests pass.
```

---

## Prompt 28 — Final Integration, Acceptance Tests, and Cleanup

```text
Continue implementing Hermit-Prov.

Previous state:
- All major features are implemented.
- Accessibility and tablet polish have been added.

Task:
Perform final integration, acceptance testing, cleanup, and documentation pass.

Requirements:
1. Run all tests and fix failures.
2. Add or complete high-level acceptance tests for the v1 product flow:
   - Open app.
   - Choose each drill.
   - Start each drill with defaults.
   - Configure each drill.
   - Use Pause/Resume.
   - Stop with confirmation.
   - Confirm qualifying drill sessions log silently.
   - Use Prompt Generator.
   - Use Timer tool.
   - Use Emotion Wheel.
   - Create/edit/delete Journal entry.
   - Change theme.
   - Change TTS settings.
   - Export/import backup.
   - View Privacy/About.
3. Verify prohibited features are absent:
   - No accounts.
   - No login.
   - No cloud sync.
   - No audio recording.
   - No microphone permission.
   - No speech recognition.
   - No notifications.
   - No ads.
   - No subscriptions.
   - No in-app purchases.
   - No AI-generated prompts.
   - No AI coaching.
4. Remove dead code, unused placeholders, and orphan screens.
5. Ensure every screen is reachable through intended navigation.
6. Ensure no debug-only placeholder text remains except intentionally marked placeholder content for prompt lists/emotion taxonomy.
7. Add developer documentation covering:
   - Local data schema.
   - Export/import schema versioning.
   - Prompt validation rules.
   - How to replace placeholder prompt lists with final human-curated lists.
   - How to configure real crash-report provider if desired.
8. Confirm app can run offline after installation.

Testing:
1. Full test suite passes.
2. Add acceptance tests where feasible.
3. Manual QA checklist included in docs for items hard to automate.

Acceptance criteria:
- Hermit-Prov v1 is internally coherent, wired together, and ready for QA/content/design finalization.
- No hanging or orphaned code remains.
- Tests pass.
```

---

# Part 8 — Final Notes for the Implementing LLM

The implementing LLM should not skip ahead.

The correct approach is:

1. Complete one prompt.
2. Run tests.
3. Fix failures.
4. Commit or checkpoint.
5. Move to the next prompt.

When in doubt, preserve the core Hermit-Prov principles:

- Offline-first.
- Local-only user data.
- No accounts.
- No recording.
- No microphone permission.
- No AI prompts or AI coaching.
- No gamified pressure.
- Simple guided practice.
- Strong test coverage for domain logic.

The app should become useful early, then become deeper and safer step by step.

