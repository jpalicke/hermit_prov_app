# Hermit-Prov TODO Checklist

This checklist is based on the **Hermit-Prov Developer Handoff Spec** and the implementation blueprint/codegen prompt sequence.

Use it as a living project tracker. The intent is to build Hermit-Prov incrementally, test-first, with every feature wired into the app as it is implemented.

---

## Status Key

- `[ ]` Not started
- `[~]` In progress
- `[x]` Done
- `[!]` Blocked / needs decision

---

## Project Principles Checklist

Keep these constraints visible during the entire project.

- [ ] App is named **Hermit-Prov**
- [ ] Flutter is preferred, but another cross-platform framework is acceptable if it preserves the spec
- [ ] App supports iOS and Android
- [ ] App supports phones and tablets
- [ ] Phones are portrait-only
- [ ] Tablets use tablet-friendly layouts, not merely scaled phone layouts
- [ ] App is English-only for v1
- [ ] App opens directly to Practice / Choose Your Drill
- [ ] No onboarding flow in v1
- [ ] All user data stays local unless the user explicitly exports it or sends a crash report
- [ ] App is fully usable offline after installation
- [ ] No accounts
- [ ] No login
- [ ] No cloud sync
- [ ] No audio recording
- [ ] No microphone permission
- [ ] No speech recognition
- [ ] No push notifications
- [ ] No local reminder notifications
- [ ] No social features
- [ ] No multiplayer
- [ ] No ads
- [ ] No subscriptions
- [ ] No in-app purchases
- [ ] Low-key external Ko-fi donation link only
- [ ] No AI-generated prompts
- [ ] No AI coaching
- [ ] No AI feedback
- [ ] No badges
- [ ] No leaderboards
- [ ] No public streaks
- [ ] No nagging reminders
- [ ] Streaks are quiet local personal stats only

---

# Milestone 0 — Repository and Project Setup

## 0.1 Repository Setup

- [ ] Create project repository
- [ ] Add README.md
- [ ] Add LICENSE file if applicable
- [ ] Add `.gitignore`
- [ ] Add basic project structure
- [ ] Add issue templates if desired
- [ ] Add pull request template if desired
- [ ] Add contribution notes if this will be open source
- [ ] Add initial manual QA checklist document
- [ ] Add this `todo.md` checklist to the repo

## 0.2 Flutter Project Setup

- [x] Create Flutter app
- [ ] Confirm app runs on iOS simulator
- [ ] Confirm app runs on Android emulator
- [ ] Confirm app runs in debug mode
- [ ] Confirm app builds in release mode locally
- [ ] Set app display name to **Hermit-Prov**
- [ ] Configure package/application IDs
- [ ] Add app versioning strategy
- [ ] Add linting configuration
- [ ] Add formatting command/process
- [ ] Add test command/process

## 0.3 Initial Dependency Decisions

- [ ] Choose state management approach
- [ ] Choose local persistence approach
- [ ] Choose routing/navigation approach
- [ ] Choose text-to-speech package
- [ ] Choose share/file picker packages for export/import
- [ ] Choose URL/email launcher package
- [ ] Choose crash-report provider or decide on no-op shell for v1 development
- [ ] Document dependency choices in README or developer docs

## 0.4 Test Infrastructure

- [ ] Confirm unit tests run
- [ ] Confirm widget tests run
- [ ] Add test helpers
- [ ] Add fake clock or timer helper
- [ ] Add fake repositories
- [ ] Add fake TTS service
- [ ] Add fake crash-report provider
- [ ] Add test data builders/factories
- [ ] Add CI test command if using CI

---

# Milestone 1 — App Shell and Navigation

## 1.1 App Entry Point

- [x] Implement `main.dart`
- [x] Implement root app widget
- [x] Add Material app
- [x] Add base theme support
- [x] Add light theme placeholder
- [x] Add dark theme placeholder
- [x] Default theme follows system appearance
- [x] App launches directly to Practice tab
- [x] No onboarding screen appears

## 1.2 Bottom Navigation

- [x] Add bottom navigation with exactly three tabs
- [x] Add Practice tab
- [x] Add History tab
- [x] Add Settings tab
- [x] Practice tab is selected by default
- [x] History tab is reachable
- [x] Settings tab is reachable
- [x] Tools is **not** in bottom navigation

## 1.3 Placeholder Screens

- [x] Add Practice placeholder
- [x] Add History placeholder
- [x] Add Settings placeholder
- [x] Add basic app scaffold
- [ ] Add consistent page title treatment
- [ ] Add shared spacing constants
- [ ] Add shared card component
- [ ] Add shared primary button component
- [ ] Add shared secondary button component

## 1.4 Tests

- [x] Widget test: app launches
- [x] Widget test: bottom navigation shows Practice, History, Settings
- [x] Widget test: Practice is initial tab
- [x] Widget test: History tab is reachable
- [x] Widget test: Settings tab is reachable

---

# Milestone 2 — Practice Home / Choose Your Drill

## 2.1 Practice Home Layout

- [x] Replace Practice placeholder with Choose Your Drill screen
- [x] Add card for Cat/Clock
- [x] Add card for Character Creation
- [x] Add card for Two-Character Scenes
- [x] Add card for A-to-C / Bad Idea / Initiation
- [x] Add card for Five Line Game Drill
- [x] Add card for Tools
- [x] Each card has a name
- [x] Each card has a short subtitle
- [x] Cards do not display saved settings
- [x] Layout works on narrow phones
- [ ] Layout has room to adapt for tablets later

## 2.2 Drill Start Placeholder Routing

- [x] Tapping Cat/Clock opens Cat/Clock start placeholder
- [x] Tapping Character Creation opens Character Creation start placeholder
- [x] Tapping Two-Character Scenes opens Two-Character Scenes start placeholder
- [x] Tapping A-to-C / Bad Idea / Initiation opens A-to-C start placeholder
- [x] Tapping Five Line Game Drill opens Five Line Game start placeholder
- [x] Tapping Tools opens Tools placeholder
- [x] Each drill start placeholder shows drill name
- [x] Each drill start placeholder shows Start button
- [x] Each drill start placeholder shows Configure button
- [x] Each drill start placeholder shows info/help button

## 2.3 Tests

- [x] Widget test: all five drill cards appear
- [x] Widget test: Tools card appears
- [x] Widget test: tapping each drill card opens correct start screen
- [x] Widget test: tapping Tools opens Tools screen
- [x] Widget test: each start screen has Start, Configure, and info/help controls

---

# Milestone 3 — Domain Models and Defaults

## 3.1 Core Enums and IDs

- [ ] Add `DrillId.catClock`
- [ ] Add `DrillId.characterCreation`
- [ ] Add `DrillId.twoCharacterScenes`
- [ ] Add `DrillId.atoC`
- [ ] Add `DrillId.fiveLineGame`
- [ ] Add `PromptCategory.objects`
- [ ] Add `PromptCategory.locations`
- [ ] Add `PromptCategory.relationships`
- [ ] Add `PromptCategory.occupations`
- [ ] Add `PromptCategory.emotions`
- [ ] Add `PromptCategory.activities`
- [ ] Add theme preference enum: system/light/dark
- [ ] Define word bucket as all prompt categories combined
- [ ] Confirm word bucket is not a separate persisted prompt category

## 3.2 Prompt Models

- [ ] Add `BuiltInPrompt` model
- [ ] Add `CustomPrompt` model
- [ ] Add prompt ID field
- [ ] Add prompt category field
- [ ] Add prompt text field
- [ ] Add created timestamp for custom prompts
- [ ] Add updated timestamp for custom prompts
- [ ] Add serialization/deserialization if needed
- [ ] Add equality behavior if needed

## 3.3 Drill Settings Models

- [ ] Add base `DrillSettings` model or per-drill settings models
- [ ] Add Cat/Clock settings
- [ ] Add Character Creation settings
- [ ] Add Two-Character Scenes settings
- [ ] Add A-to-C settings
- [ ] Add Five Line Game settings
- [ ] Add saved prompt category selections
- [ ] Add Hands-Free Mode flag per drill/session configuration
- [ ] Add default factory for every drill

## 3.4 Drill Defaults

- [ ] Cat/Clock default speaking duration is 3 minutes
- [ ] Cat/Clock default regroup duration is 30 seconds
- [ ] Cat/Clock default prompt source is word + word
- [ ] Cat/Clock loops until stopped
- [ ] Character Creation default character count is 2
- [ ] Character Creation default segment duration is 60 seconds
- [ ] Character Creation allowed segment durations are 60/90/120 seconds
- [ ] Character Creation default prompt source is word bucket
- [ ] Character Creation has finite cycle, no indefinite loop
- [ ] Two-Character Scenes default scene duration is 90 seconds
- [ ] Two-Character Scenes default regroup duration is 30 seconds
- [ ] Two-Character Scenes default prompt source is word bucket
- [ ] Two-Character Scenes loops until stopped
- [ ] A-to-C default interval is 30 seconds
- [ ] A-to-C allowed intervals are 15/30/45/60 seconds
- [ ] A-to-C default prompt source is word bucket
- [ ] A-to-C loops until stopped
- [ ] Five Line Game default is prompt only
- [ ] Five Line Game auto-advance default is off
- [ ] Five Line Game allowed auto-advance intervals are 30/60/90 seconds
- [ ] Five Line Game default prompt source is word bucket

## 3.5 Practice History and Journal Models

- [ ] Add `PracticeSession` model
- [ ] PracticeSession stores drill ID/name
- [ ] PracticeSession stores date/time
- [ ] PracticeSession stores duration
- [ ] PracticeSession does not store prompts used
- [ ] PracticeSession does not store settings used
- [ ] Add `JournalEntry` model
- [ ] JournalEntry stores date/createdAt
- [ ] JournalEntry stores updatedAt
- [ ] JournalEntry stores optional drill tag
- [ ] JournalEntry stores body text
- [ ] JournalEntry does not require a linked practice session

## 3.6 App Preferences Model

- [ ] Add `AppPreferences` model
- [ ] Add theme preference
- [ ] Add TTS voice setting
- [ ] Add TTS speaking rate setting
- [ ] Add any other safe app-level preference fields
- [ ] Do not add persistent crash-report opt-in preference

## 3.7 Repository Interfaces

- [ ] Add `PromptRepository` interface
- [ ] Add `DrillSettingsRepository` interface
- [ ] Add `PracticeHistoryRepository` interface
- [ ] Add `JournalRepository` interface
- [ ] Add `AppPreferencesRepository` interface
- [ ] Keep repository interfaces independent of a database package
- [ ] Add clear method contracts
- [ ] Add error/result handling strategy

## 3.8 Tests

- [ ] Unit test: word bucket expands to all six categories
- [ ] Unit test: Cat/Clock defaults
- [ ] Unit test: Character Creation defaults
- [ ] Unit test: Two-Character Scenes defaults
- [ ] Unit test: A-to-C defaults
- [ ] Unit test: Five Line Game defaults
- [ ] Unit test: Character Creation duration options
- [ ] Unit test: A-to-C interval options
- [ ] Unit test: Five Line Game interval options
- [ ] Unit test: PracticeSession excludes prompts/settings
- [ ] Unit test: AppPreferences default theme is system

---

# Milestone 4 — In-Memory Repositories and Seed Prompts

## 4.1 In-Memory Repositories

- [ ] Implement in-memory PromptRepository
- [ ] Implement in-memory DrillSettingsRepository
- [ ] Implement in-memory PracticeHistoryRepository
- [ ] Implement in-memory JournalRepository
- [ ] Implement in-memory AppPreferencesRepository
- [ ] Wire repositories into app using chosen dependency pattern
- [ ] Ensure repositories can be swapped later for durable local persistence
- [ ] Ensure tests can inject fake/in-memory repositories

## 4.2 Seed Prompt System

- [ ] Add seed prompt source
- [ ] Add placeholder built-in Object prompts
- [ ] Add placeholder built-in Location prompts
- [ ] Add placeholder built-in Relationship prompts
- [ ] Add placeholder built-in Occupation prompts
- [ ] Add placeholder built-in Emotion prompts
- [ ] Add placeholder built-in Activity prompts
- [ ] Clearly mark seed prompts as placeholder content
- [ ] Ensure final robust prompt lists are documented as separate content task
- [ ] Built-in prompts are read-only
- [ ] Custom prompts are stored separately

## 4.3 Repository Behavior

- [ ] Built-in prompts load by category
- [ ] Built-in prompts load into word bucket
- [ ] Custom prompts can be added
- [ ] Custom prompts can be listed by category
- [ ] Built-in prompts cannot be edited
- [ ] Built-in prompts cannot be deleted
- [ ] Drill settings repository returns defaults if no saved settings exist
- [ ] Drill settings repository returns saved settings after update
- [ ] App preferences repository returns defaults if none saved

## 4.4 Tests

- [ ] Repository test: built-in prompts load for every category
- [ ] Repository test: custom prompts are separate from built-in prompts
- [ ] Repository test: built-in prompts cannot be edited
- [ ] Repository test: built-in prompts cannot be deleted
- [ ] Repository test: drill settings defaults are returned
- [ ] Repository test: saved drill settings override defaults
- [ ] Repository test: app preferences defaults are returned
- [ ] Repository test: saved app preferences are returned

---

# Milestone 5 — Prompt Picker and Custom Prompt Validation

## 5.1 Prompt Picker

- [ ] Add PromptPicker service
- [ ] Pick random prompt from one category
- [ ] Pick random prompt from multiple categories
- [ ] Pick random prompt from word bucket
- [ ] Include built-in prompts automatically
- [ ] Include custom prompts automatically
- [ ] Mix built-in and custom prompts without extra user setting
- [ ] Do not implement built-in-only/custom-only/both filters
- [ ] Handle empty category gracefully
- [ ] Handle empty prompt pool gracefully

## 5.2 Custom Prompt Validator

- [ ] Add CustomPromptValidator
- [ ] Validation happens entirely on-device
- [ ] No network calls
- [ ] Broadly block slurs
- [ ] Narrowly block clearly explicit/graphic sexual content
- [ ] Allow non-graphic adult-life prompts
- [ ] Allow “bad date”
- [ ] Allow “affair”
- [ ] Allow “crush”
- [ ] Allow “flirting”
- [ ] Allow “awkward hookup”
- [ ] Allow “divorce”
- [ ] Return generic validation failure only
- [ ] Do not expose specific blocked reason to user
- [ ] Do not log blocked attempts
- [ ] Do not save rejected prompts

## 5.3 Tests

- [ ] Unit test: pick from single category
- [ ] Unit test: pick from multiple categories
- [ ] Unit test: pick from word bucket
- [ ] Unit test: built-in and custom prompts are both eligible
- [ ] Unit test: empty category behavior
- [ ] Unit test: slur blocking
- [ ] Unit test: explicit/graphic sexual content blocking
- [ ] Unit test: allowed adult-life prompts pass
- [ ] Repository test: rejected prompt is not saved
- [ ] Repository test: rejected prompt is not logged

---

# Milestone 6 — Custom Prompt Management UI

## 6.1 Custom Prompt Screen

- [ ] Add Custom Prompts screen
- [ ] Make screen reachable from Tools or Prompt Generator
- [ ] Show custom prompts
- [ ] Show prompt category for each custom prompt
- [ ] Allow category selection when adding prompt
- [ ] Allow category selection when editing prompt
- [ ] Keep UI simple and accessible

## 6.2 Custom Prompt CRUD

- [ ] Add custom prompt
- [ ] Edit custom prompt
- [ ] Delete custom prompt
- [ ] Confirm deletion if appropriate
- [ ] Validate custom prompt before saving
- [ ] Show simple generic error if blocked
- [ ] Do not show reason for blocked prompt
- [ ] Do not log blocked attempt
- [ ] Built-in prompts are not editable
- [ ] Built-in prompts are not deletable
- [ ] Built-in prompts are not disableable

## 6.3 Tests

- [ ] Widget test: Custom Prompts screen is reachable
- [ ] Widget test: valid custom prompt can be added
- [ ] Widget test: custom prompt can be edited
- [ ] Widget test: custom prompt can be deleted
- [ ] Widget test: blocked prompt shows generic error
- [ ] Widget test: blocked prompt is not listed afterward
- [ ] Widget test: built-in prompts are not editable through this screen
- [ ] Widget test: built-in prompts are not deletable through this screen

---

# Milestone 7 — Tools: Standalone Prompt Generator

## 7.1 Tools Screen

- [ ] Replace Tools placeholder with real Tools screen
- [ ] Add Prompt Generator item
- [ ] Add Timer placeholder item
- [ ] Add Emotion Wheel placeholder item
- [ ] Add Practice Journal placeholder/link item
- [ ] Tools remains reachable from Practice home card
- [ ] Tools is not in bottom navigation

## 7.2 Prompt Generator Tool

- [ ] Add Prompt Generator screen
- [ ] Allow selecting one prompt category
- [ ] Allow selecting multiple prompt categories
- [ ] Allow selecting word bucket
- [ ] Default selection is word bucket
- [ ] Add New Prompt button
- [ ] Display generated prompt clearly
- [ ] Use built-in and custom prompts automatically
- [ ] Handle no prompt available gracefully

## 7.3 Prompt Generator Auto-Advance

- [ ] Add optional auto-advance toggle
- [ ] Auto-advance default is off
- [ ] Add 15-second interval option
- [ ] Add 30-second interval option
- [ ] Add 45-second interval option
- [ ] Add 60-second interval option
- [ ] Auto-advance refreshes prompt on selected interval
- [ ] Auto-advance stops when leaving screen
- [ ] Auto-advance pauses/disposes cleanly when widget is disposed

## 7.4 Tests

- [ ] Widget test: Tools screen shows Prompt Generator
- [ ] Widget test: Tools screen shows Timer placeholder
- [ ] Widget test: Tools screen shows Emotion Wheel placeholder
- [ ] Widget test: Tools screen shows Practice Journal item
- [ ] Widget test: Prompt Generator is reachable
- [ ] Widget test: New Prompt displays prompt
- [ ] Widget test: category selection changes eligible prompt pool
- [ ] Widget/unit test: auto-advance changes prompt
- [ ] Widget/unit test: auto-advance is cancelled when leaving screen

---

# Milestone 8 — Reusable Timer and Session Engine

## 8.1 Timer Segment Model

- [ ] Add timer segment model
- [ ] Segment has ID/type
- [ ] Segment has duration
- [ ] Segment can have display label
- [ ] Segment can have prompt payload
- [ ] Segment can indicate regroup/rest/speaking/prompt interval/character pass
- [ ] Segment model is independent of widgets

## 8.2 Drill Session Controller

- [ ] Add DrillSessionController or equivalent state machine
- [ ] Support start
- [ ] Support manual/fake tick for tests
- [ ] Support pause
- [ ] Support resume
- [ ] Support stop request
- [ ] Support segment completion
- [ ] Support finite session completion
- [ ] Support looping session sequences
- [ ] Track current segment
- [ ] Track remaining segment time
- [ ] Track elapsed session time
- [ ] Track whether paused
- [ ] Track whether complete
- [ ] Track whether stopped
- [ ] Avoid depending on real time for unit tests

## 8.3 Progress Calculation

- [ ] Add current segment progress
- [ ] Add current rep/cycle progress where appropriate
- [ ] Progress works for finite cycles
- [ ] Progress works for looping cycles
- [ ] Progress resets per current rep/cycle for looping drills
- [ ] Progress does not attempt unknown total session progress for indefinite loops

## 8.4 Pause/Resume Behavior

- [ ] Pause freezes remaining time
- [ ] Pause freezes prompt/segment changes
- [ ] Resume continues from same state
- [ ] Pause does not complete segments
- [ ] Resume does not restart current segment

## 8.5 Tests

- [ ] Unit test: countdown decreases with ticks
- [ ] Unit test: segment completion advances to next segment
- [ ] Unit test: looping sequence restarts after final segment
- [ ] Unit test: finite sequence completes after final segment
- [ ] Unit test: pause freezes time
- [ ] Unit test: pause freezes segment changes
- [ ] Unit test: resume continues correctly
- [ ] Unit test: progress calculation for simple segment
- [ ] Unit test: progress calculation for looping cycle
- [ ] Unit test: progress calculation for finite cycle

---

# Milestone 9 — Reusable Drill UI Shell

## 9.1 Drill Start Screen Pattern

- [ ] Replace drill placeholders with reusable start screen
- [ ] Show drill name
- [ ] Show short description/subtitle
- [ ] Show Start button
- [ ] Show Configure button
- [ ] Show info/help button
- [ ] Start uses saved drill settings
- [ ] Start uses defaults if no saved settings exist

## 9.2 Configure Screen Pattern

- [ ] Add reusable configure screen structure
- [ ] Allow drill-specific settings sections
- [ ] Save settings when user starts from configuration
- [ ] Persist changed settings locally
- [ ] Return to start screen when appropriate
- [ ] Keep configuration UI simple

## 9.3 Active Drill Session Shell

- [ ] Add reusable active drill session screen
- [ ] Show large countdown timer when applicable
- [ ] Show circular progress ring when applicable
- [ ] Show prompt/label display area
- [ ] Add Pause/Resume button
- [ ] Add Stop/End button
- [ ] Stop/End shows confirmation dialog
- [ ] Confirming stop returns to drill start screen
- [ ] Pause freezes session controller
- [ ] Resume continues session controller

## 9.4 Temporary Fake Drill Integration

- [ ] Wire one simple fake/test drill through shell
- [ ] Confirm session shell works before building real drills
- [ ] Remove fake drill once real drill is integrated
- [ ] Ensure no orphan fake screen remains

## 9.5 Tests

- [ ] Widget test: drill start shows Start, Configure, info/help
- [ ] Widget test: Configure can update simple saved setting
- [ ] Widget test: Start launches session shell
- [ ] Widget test: Pause changes to Resume
- [ ] Widget/unit test: pause freezes displayed timer
- [ ] Widget test: Stop/End shows confirmation
- [ ] Widget test: confirming stop returns to start screen
- [ ] Test no fake drill remains after real drills are wired

---

# Milestone 10 — Drill: Cat/Clock

## 10.1 Cat/Clock Flow

- [ ] Generate two prompts at start of each rep
- [ ] Speaking segment defaults to 3 minutes
- [ ] Regroup segment defaults to 30 seconds
- [ ] Speaking segment shows both prompts
- [ ] Regroup segment shows countdown
- [ ] After regroup, generate new prompt pair
- [ ] Continue until user manually stops
- [ ] Pause/resume works
- [ ] Stop confirmation works

## 10.2 Cat/Clock Configuration

- [ ] Configure speaking duration
- [ ] Configure regroup duration
- [ ] Configure prompt 1 category source
- [ ] Configure prompt 2 category source
- [ ] Default prompt 1 source is word bucket
- [ ] Default prompt 2 source is word bucket
- [ ] Allow category combinations such as object + location
- [ ] Save configuration locally
- [ ] Start uses saved configuration

## 10.3 Cat/Clock UI

- [ ] Start screen uses reusable drill start pattern
- [ ] Configure screen uses reusable configure pattern
- [ ] Session screen uses reusable session shell
- [ ] Show both prompts prominently
- [ ] Show countdown
- [ ] Show circular progress for current rep/cycle
- [ ] Keep UI uncluttered
- [ ] Do not show excessive instructions during drill

## 10.4 Tests

- [ ] Unit test: Cat/Clock builds speaking + regroup sequence
- [ ] Unit test: Cat/Clock sequence loops
- [ ] Unit test: prompts regenerate each speaking rep
- [ ] Widget test: Start launches with two prompts
- [ ] Widget test: Configure saves speaking duration
- [ ] Widget test: Configure saves regroup duration
- [ ] Widget test: Configure saves prompt categories
- [ ] Widget test: Pause/Resume works
- [ ] Widget test: Stop confirmation works

---

# Milestone 11 — Drill: Two-Character Scenes

## 11.1 Two-Character Scenes Flow

- [ ] Generate one prompt
- [ ] Scene timer defaults to 90 seconds
- [ ] Regroup timer defaults to 30 seconds
- [ ] After regroup, generate new prompt
- [ ] Continue until user manually stops
- [ ] Pause/resume works
- [ ] Stop confirmation works

## 11.2 Two-Character Scenes Configuration

- [ ] Configure scene duration
- [ ] Configure regroup duration
- [ ] Configure prompt category source
- [ ] Default prompt source is word bucket
- [ ] Save configuration locally
- [ ] Start uses saved configuration

## 11.3 Two-Character Scenes UI

- [ ] Show prompt
- [ ] Show countdown
- [ ] Show circular progress for current rep/cycle
- [ ] Do not display which character is speaking
- [ ] Do not include character-switching labels
- [ ] Keep drill screen simple

## 11.4 Tests

- [ ] Unit test: sequence is prompt scene + regroup loop
- [ ] Unit test: prompt regenerates after regroup
- [ ] Widget test: Start launches with one prompt
- [ ] Widget test: no character speaker labels appear
- [ ] Widget test: Configure saves scene duration
- [ ] Widget test: Configure saves regroup duration
- [ ] Widget test: Configure saves category settings
- [ ] Widget test: Pause/Resume works
- [ ] Widget test: Stop confirmation works

---

# Milestone 12 — Drill: A-to-C / Bad Idea / Initiation

## 12.1 A-to-C Flow

- [ ] Treat as one drill with full name
- [ ] Show one prompt
- [ ] Default prompt interval is 30 seconds
- [ ] Prompt changes automatically each interval
- [ ] Repeat rapid-fire until user stops
- [ ] No regroup segment
- [ ] Pause/resume works
- [ ] Stop confirmation works

## 12.2 A-to-C Configuration

- [ ] Configure interval
- [ ] Allow 15 seconds
- [ ] Allow 30 seconds
- [ ] Allow 45 seconds
- [ ] Allow 60 seconds
- [ ] Configure prompt category source
- [ ] Default prompt source is word bucket
- [ ] Save configuration locally
- [ ] Start uses saved configuration

## 12.3 A-to-C UI

- [ ] Show current prompt
- [ ] Show countdown for current interval
- [ ] Show circular progress for current interval/rep
- [ ] Keep screen uncluttered
- [ ] Do not split into separate A-to-C, Bad Idea, and Initiation drills

## 12.4 Tests

- [ ] Unit test: default interval is 30 seconds
- [ ] Unit test: allowed intervals are 15/30/45/60
- [ ] Unit test: prompt changes each interval
- [ ] Unit test: flow loops until stopped
- [ ] Widget test: Start launches with one prompt
- [ ] Widget test: Configure saves interval
- [ ] Widget test: Configure saves category settings
- [ ] Widget test: Pause/Resume freezes prompt changes
- [ ] Widget test: Stop confirmation works

---

# Milestone 13 — Drill: Five Line Game

## 13.1 Five Line Game Default Flow

- [ ] Show one prompt
- [ ] No timer by default
- [ ] Show New Prompt button
- [ ] Tapping New Prompt generates another prompt
- [ ] Prompt source defaults to word bucket
- [ ] No line tracking
- [ ] No speaking detection

## 13.2 Forbidden Five Line UI Elements

- [ ] Do not show Line 1
- [ ] Do not show Line 2
- [ ] Do not show Line 3
- [ ] Do not show Line 4
- [ ] Do not show Line 5
- [ ] Do not show initiation/response/heightening/turn/button labels
- [ ] Do not attempt to know which line is being spoken

## 13.3 Optional Auto-Advance

- [ ] Auto-advance default is off
- [ ] Allow 30-second interval
- [ ] Allow 60-second interval
- [ ] Allow 90-second interval
- [ ] If enabled, show countdown/progress
- [ ] If enabled, generate prompt at each interval
- [ ] Pause/resume applies only when auto-advance is on
- [ ] Save auto-advance settings locally

## 13.4 Configuration

- [ ] Configure prompt category source
- [ ] Configure auto-advance on/off
- [ ] Configure auto-advance interval
- [ ] Save configuration locally
- [ ] Start uses saved configuration

## 13.5 Tests

- [ ] Widget test: default screen shows prompt and New Prompt
- [ ] Widget test: default screen shows no timer
- [ ] Widget test: New Prompt changes prompt
- [ ] Widget test: no Line 1–5 labels appear
- [ ] Widget test: no structural scene labels appear
- [ ] Widget/unit test: auto-advance changes prompts
- [ ] Widget test: Configure saves category settings
- [ ] Widget test: Configure saves auto-advance settings
- [ ] Widget test: Pause/Resume works when auto-advance is on

---

# Milestone 14 — Character Creation Cycle Logic

## 14.1 Cycle Builder

- [ ] Add CharacterCreationCycleBuilder
- [ ] Default character count is 2
- [ ] Maximum character count is 5
- [ ] Allowed segment durations are 60/90/120 seconds
- [ ] Each character has first pass
- [ ] Each character has return pass
- [ ] Cycle is finite
- [ ] Cycle does not loop by default
- [ ] Total duration scales with characters × 2 × segment duration

## 14.2 Cycle Ordering

- [ ] 2-character cycle: Character 1
- [ ] 2-character cycle: Character 2
- [ ] 2-character cycle: Return to Character 1
- [ ] 2-character cycle: Return to Character 2
- [ ] 5-character cycle includes Character 1–5 first passes
- [ ] 5-character cycle includes Return to Character 1–5
- [ ] Segment metadata identifies first pass vs return pass
- [ ] Segment metadata identifies character number

## 14.3 Tests

- [ ] Unit test: default 2-character cycle
- [ ] Unit test: 5-character cycle
- [ ] Unit test: total duration calculation
- [ ] Unit test: allowed segment durations
- [ ] Unit test: invalid segment duration behavior
- [ ] Unit test: invalid character count behavior
- [ ] Unit test: return-pass labels
- [ ] Unit test: first-pass metadata
- [ ] Unit test: return-pass metadata

---

# Milestone 15 — Character Creation UI

## 15.1 Character Creation Configuration

- [ ] Configure number of characters
- [ ] Default number of characters is 2
- [ ] Max number of characters is 5
- [ ] Configure segment duration
- [ ] Segment duration options are 60/90/120 seconds
- [ ] Configure prompt category source
- [ ] Default prompt source is word bucket
- [ ] Save settings locally
- [ ] Start uses saved configuration

## 15.2 Normal Mode Session

- [ ] Show “Character N” during first pass
- [ ] Show “Return to Character N” during return pass
- [ ] Show countdown
- [ ] Show circular progress for cycle
- [ ] Show Pause/Resume
- [ ] Show Stop/End with confirmation
- [ ] Session ends after full cycle
- [ ] Return to Start screen after cycle completes

## 15.3 Normal Mode Prompt Generation

- [ ] Prompt generation is manual and optional
- [ ] Show Generate Prompt button only on first passes
- [ ] Generate and display prompt if user taps button
- [ ] Do not show Generate Prompt button on return passes
- [ ] Do not show original prompt on return passes
- [ ] Do not provide Character List
- [ ] Do not provide review button
- [ ] Remembering is part of the drill

## 15.4 Tests

- [ ] Widget test: default setup launches Character 1
- [ ] Widget test: Generate Prompt appears on first pass
- [ ] Widget test: Generate Prompt does not appear on return pass
- [ ] Widget test: generated prompt appears during first pass
- [ ] Widget test: return pass shows “Return to Character N”
- [ ] Widget test: return pass does not show original prompt
- [ ] Widget test: no Character List button exists
- [ ] Widget test: no review button exists
- [ ] Widget test: session completes after final return pass
- [ ] Widget test: Configure saves character count
- [ ] Widget test: Configure saves segment duration
- [ ] Widget test: Configure saves prompt category source

---

# Milestone 16 — Text-to-Speech Service and Global Settings

## 16.1 TTS Service

- [ ] Add TtsService interface
- [ ] Add speak method
- [ ] Add stop method
- [ ] Add voice selection support if available
- [ ] Add speaking rate support
- [ ] Add fake TTS service for tests
- [ ] Add real TTS implementation
- [ ] Ensure no microphone permission is added
- [ ] Ensure no speech recognition permission is added
- [ ] Ensure no recording permission is added

## 16.2 Global TTS Preferences

- [ ] Add TTS voice to AppPreferences
- [ ] Add TTS speaking rate to AppPreferences
- [ ] Persist TTS settings locally
- [ ] TTS settings apply globally
- [ ] Hands-Free Mode is not an app-wide default
- [ ] Hands-Free Mode remains per drill/session configuration

## 16.3 Settings UI

- [ ] Add Text-to-Speech section to Settings
- [ ] Show voice setting if available
- [ ] Show speaking rate setting
- [ ] Allow changing speaking rate
- [ ] Save TTS settings
- [ ] Keep settings UI accessible

## 16.4 Tests

- [ ] Unit test: fake TTS captures spoken text
- [ ] Repository test: TTS voice setting persists
- [ ] Repository test: TTS rate setting persists
- [ ] Widget test: TTS settings screen is reachable
- [ ] Widget test: changing speaking rate saves preference
- [ ] Static/manual check: no microphone permission
- [ ] Static/manual check: no speech-recognition permission

---

# Milestone 17 — Hands-Free Announcement Policy

## 17.1 General Policy

- [ ] Add HandsFreeAnnouncementPolicy
- [ ] For non-character prompt segments, read prompt aloud when it appears
- [ ] Prompt reading replaces “begin”
- [ ] Do not announce “begin” when prompt is read
- [ ] Segments longer than 30 seconds get timer announcements
- [ ] Announce “30 seconds” for segments longer than 30 seconds
- [ ] Announce “10 seconds” for segments longer than 30 seconds
- [ ] Announce “time” for segments longer than 30 seconds
- [ ] Exactly 30-second segments get no timer announcements
- [ ] If exactly 30-second segment has prompt, read only prompt
- [ ] If exactly 30-second segment has no prompt, stay silent
- [ ] Regroup segments stay silent
- [ ] Paused state suppresses announcements
- [ ] Resume continues policy from current state

## 17.2 Character Creation Policy

- [ ] In Hands-Free Mode, generate prompt automatically on first passes
- [ ] First pass announcement is “Character N: prompt”
- [ ] Return pass announcement is “Character N”
- [ ] Do not say “Return to Character N” in TTS
- [ ] Do not speak original prompt on return pass
- [ ] Do not display original prompt on return pass

## 17.3 Tests

- [ ] Unit test: prompt reading replaces begin
- [ ] Unit test: segment over 30 seconds announces 30 seconds
- [ ] Unit test: segment over 30 seconds announces 10 seconds
- [ ] Unit test: segment over 30 seconds announces time
- [ ] Unit test: exactly 30-second segment has no timer announcements
- [ ] Unit test: exactly 30-second prompt segment reads only prompt
- [ ] Unit test: exactly 30-second no-prompt segment stays silent
- [ ] Unit test: regroup is silent
- [ ] Unit test: A-to-C default behavior
- [ ] Unit test: Character Creation first-pass announcement
- [ ] Unit test: Character Creation return-pass announcement
- [ ] Unit test: paused state suppresses announcements

---

# Milestone 18 — Wire Hands-Free Mode Into Drills

## 18.1 Shared Hands-Free Wiring

- [ ] Add Hands-Free Mode toggle to drill configuration where appropriate
- [ ] Hands-Free Mode default is off
- [ ] Use global TTS settings
- [ ] Use fake TTS in tests
- [ ] Stop button calls TTS stop
- [ ] Pause suppresses announcements
- [ ] Resume continues announcement behavior

## 18.2 Cat/Clock Hands-Free

- [ ] Read both prompts together at start of speaking rep
- [ ] Example: “cat, clock”
- [ ] Stay silent during regroup
- [ ] For 3-minute speaking segment, announce 30 seconds
- [ ] For 3-minute speaking segment, announce 10 seconds
- [ ] For 3-minute speaking segment, announce time

## 18.3 Two-Character Scenes Hands-Free

- [ ] Read prompt when scene starts
- [ ] Announce 30 seconds for 90-second scene
- [ ] Announce 10 seconds for 90-second scene
- [ ] Announce time for 90-second scene
- [ ] Stay silent during regroup

## 18.4 A-to-C Hands-Free

- [ ] Read each new prompt aloud
- [ ] Default 30-second interval has no timer announcements
- [ ] Longer intervals follow standard announcement policy
- [ ] Pause freezes prompt changes and announcements

## 18.5 Five Line Game Hands-Free

- [ ] Read prompt when shown
- [ ] If auto-advance is off, no timer announcements
- [ ] If auto-advance is on, read each new prompt
- [ ] If interval is 30 seconds, no timer announcements
- [ ] If interval is longer than 30 seconds, use standard timer announcements

## 18.6 Character Creation Hands-Free

- [ ] Automatically generate prompts on first passes
- [ ] Display generated prompt during first pass
- [ ] Speak “Character N: prompt”
- [ ] On return pass, speak only “Character N”
- [ ] Do not display original prompt on return pass
- [ ] Do not speak original prompt on return pass

## 18.7 Tests

- [ ] Widget/unit test: Hands-Free default is off
- [ ] Widget/unit test: Cat/Clock speaks prompt pair
- [ ] Widget/unit test: Cat/Clock regroup is silent
- [ ] Widget/unit test: Two-Character Scenes speaks prompt
- [ ] Widget/unit test: A-to-C 30-second prompt has no timer announcement
- [ ] Widget/unit test: Five Line Game speaks prompt
- [ ] Widget/unit test: Character Creation auto-generates prompt in Hands-Free
- [ ] Widget/unit test: Character Creation first pass speaks label and prompt
- [ ] Widget/unit test: Character Creation return pass speaks only character label
- [ ] Widget/unit test: pause suppresses announcements
- [ ] Widget/unit test: stop calls TTS stop

---

# Milestone 19 — Practice History

## 19.1 Session Logging

- [ ] Add session logging service
- [ ] Log drill session if duration is at least 30 seconds
- [ ] Do not log sessions under 30 seconds
- [ ] Log drill ID/name
- [ ] Log date/time
- [ ] Log duration
- [ ] Do not log prompts used
- [ ] Do not log settings used
- [ ] Logging is silent
- [ ] No “Session saved” toast/snackbar
- [ ] No completion summary screen

## 19.2 Wire Logging Into Drills

- [ ] Wire logging into Cat/Clock
- [ ] Wire logging into Character Creation
- [ ] Wire logging into Two-Character Scenes
- [ ] Wire logging into A-to-C
- [ ] Wire logging into Five Line Game
- [ ] Do not log standalone Prompt Generator usage
- [ ] Do not log standalone Timer usage
- [ ] Do not log Emotion Wheel usage
- [ ] Do not log Journal usage

## 19.3 Stats Calculations

- [ ] Calculate total practice time
- [ ] Calculate sessions completed
- [ ] Calculate current streak
- [ ] Calculate longest streak
- [ ] Calculate breakdown by drill
- [ ] Practice day requires at least one qualifying drill session
- [ ] Journal entries do not count toward streak
- [ ] Standalone tools do not count toward streak

## 19.4 History UI

- [ ] History tab shows summary first
- [ ] Add Practice Stats section/button
- [ ] Add Journal section/button placeholder if not already done
- [ ] Show total practice time
- [ ] Show sessions completed
- [ ] Show current streak
- [ ] Show longest streak
- [ ] Show breakdown by drill
- [ ] Show recent sessions
- [ ] Recent list shows most recent 20 sessions
- [ ] No date filters in v1
- [ ] No drill filters in v1
- [ ] No individual session deletion in v1

## 19.5 Tests

- [ ] Unit test: under 30 seconds does not log
- [ ] Unit test: exactly 30 seconds logs
- [ ] Unit test: over 30 seconds logs
- [ ] Unit test: total practice time
- [ ] Unit test: sessions completed
- [ ] Unit test: current streak
- [ ] Unit test: longest streak
- [ ] Unit test: breakdown by drill
- [ ] Unit test: standalone tools do not affect streaks
- [ ] Unit test: journal entries do not affect streaks
- [ ] Widget test: History shows Practice Stats section/button
- [ ] Widget test: recent list shows most recent 20 sessions
- [ ] Widget test: no individual delete control is present

---

# Milestone 20 — Practice Journal

## 20.1 Journal Access

- [ ] Journal is accessible from History tab
- [ ] Journal is accessible from Tools section
- [ ] History tab has separate Practice Stats and Journal subsections/buttons
- [ ] Journal does not require a completed practice session
- [ ] Journal is optional

## 20.2 Journal CRUD

- [ ] Create journal entry
- [ ] Edit journal entry
- [ ] Delete journal entry
- [ ] Store created date
- [ ] Store updated date
- [ ] Store optional drill tag
- [ ] Store body text
- [ ] Do not require link to specific session

## 20.3 Journal List

- [ ] Show entries newest-first
- [ ] Show date
- [ ] Show optional drill tag
- [ ] Show short preview
- [ ] No search in v1
- [ ] No filters in v1

## 20.4 Tests

- [ ] Widget test: Journal reachable from History
- [ ] Widget test: Journal reachable from Tools
- [ ] Widget test: create entry
- [ ] Widget test: edit entry
- [ ] Widget test: delete entry
- [ ] Unit/widget test: entries sort newest-first
- [ ] Unit test: journal entries do not affect streaks

---

# Milestone 21 — Standalone Timer Tool

## 21.1 Timer Tool Access

- [ ] Timer tool is reachable from Tools
- [ ] Timer tool does not appear as bottom nav item
- [ ] Timer tool is clearly separate from drill timers
- [ ] Timer tool usage does not count toward history/streaks

## 21.2 Simple Countdown Mode

- [ ] User can configure countdown duration
- [ ] User can start countdown
- [ ] User can pause countdown
- [ ] User can resume countdown
- [ ] User can stop/reset countdown
- [ ] Show large timer
- [ ] Show progress indicator if appropriate

## 21.3 Interval Cycle Mode

- [ ] User can configure work time
- [ ] User can configure regroup/rest time
- [ ] Timer alternates work/rest
- [ ] Timer repeats cycle until stopped
- [ ] Pause/resume works
- [ ] Stop/reset works
- [ ] Keep UI simple

## 21.4 Tests

- [ ] Widget test: Timer tool reachable
- [ ] Unit/widget test: simple countdown completes
- [ ] Unit/widget test: interval alternates work/rest
- [ ] Widget test: pause/resume
- [ ] Widget test: stop/reset
- [ ] Unit test: Timer tool does not create practice history records

---

# Milestone 22 — Interactive Emotion Wheel

## 22.1 Emotion Wheel Access

- [ ] Emotion Wheel reachable from Tools
- [ ] Emotion Wheel does not appear in bottom nav
- [ ] Emotion Wheel is self-contained

## 22.2 Emotion Wheel Interaction

- [ ] Show broad emotion categories
- [ ] Allow tapping broad emotion category
- [ ] Reveal more specific emotions
- [ ] Allow selecting specific emotion
- [ ] Display selected emotion as prompt within tool
- [ ] Do not send selected emotion into drills in v1
- [ ] Keep UI interactive, not static image
- [ ] Keep UI accessible

## 22.3 Content Safety

- [ ] Use original placeholder taxonomy for now
- [ ] Do not copy protected emotion wheel images
- [ ] Do not copy protected article text
- [ ] Document final taxonomy as separate content/design task

## 22.4 Tests

- [ ] Widget test: Emotion Wheel reachable from Tools
- [ ] Widget test: broad categories appear
- [ ] Widget test: tapping category reveals specific emotions
- [ ] Widget test: selecting emotion displays selected emotion
- [ ] Widget test: no “send to drill” action exists
- [ ] Accessibility/widget test: emotion controls have labels

---

# Milestone 23 — Settings

## 23.1 Settings Sections

- [ ] Add Appearance section
- [ ] Add Text-to-Speech section
- [ ] Add Drill Defaults section
- [ ] Add Data Backup section placeholder
- [ ] Add Privacy/About section placeholder
- [ ] Add Support/Donate section placeholder

## 23.2 Appearance Settings

- [ ] Add System theme option
- [ ] Add Light theme option
- [ ] Add Dark theme option
- [ ] Default is System
- [ ] Theme preference persists locally
- [ ] App applies selected theme
- [ ] Theme changes do not require restart if practical

## 23.3 Reset Drill Defaults

- [ ] Add Reset Drill Defaults action
- [ ] Show standard confirmation dialog
- [ ] Restore all drill timings to defaults
- [ ] Restore all prompt category selections to defaults
- [ ] Restore all drill-specific options to defaults
- [ ] Do not delete custom prompts
- [ ] Do not delete journal entries
- [ ] Do not delete practice history
- [ ] Do not reset app theme
- [ ] Do not reset TTS settings unless specifically part of drill defaults

## 23.4 Reset All Data

- [ ] Add Reset All Data action
- [ ] Show standard confirmation dialog
- [ ] Delete custom prompts
- [ ] Delete journal entries
- [ ] Delete practice history
- [ ] Reset saved drill settings
- [ ] Reset theme preference
- [ ] Reset TTS settings
- [ ] Reset other local preferences
- [ ] No need to type RESET
- [ ] Built-in prompts remain available after reset

## 23.5 Tests

- [ ] Widget test: Settings sections appear
- [ ] Widget test: theme preference can be changed
- [ ] Repository/widget test: theme preference persists
- [ ] Unit/widget test: Reset Drill Defaults restores drill defaults
- [ ] Unit/widget test: Reset Drill Defaults preserves custom prompts
- [ ] Unit/widget test: Reset Drill Defaults preserves journal entries
- [ ] Unit/widget test: Reset Drill Defaults preserves practice history
- [ ] Unit/widget test: Reset All Data clears expected local data
- [ ] Unit/widget test: Reset All Data preserves built-in prompts
- [ ] Widget test: reset actions show confirmation dialogs

---

# Milestone 24 — JSON Export / Import Backup

## 24.1 Data Backup UI

- [ ] Add Export Data button
- [ ] Add Import Data button
- [ ] Data Backup appears only in Settings
- [ ] Export/import does not appear on History screen
- [ ] Export/import does not appear on Journal screen
- [ ] Show local-only backup warning near Export/Import
- [ ] Warning says data stays on this device unless exported
- [ ] Warning says uninstalling or switching devices may delete local data

## 24.2 JSON Export

- [ ] Generate one JSON backup file
- [ ] Use native share/save flow where available
- [ ] Include schema version
- [ ] Include app/export version metadata
- [ ] Include custom prompts
- [ ] Include journal entries
- [ ] Include practice history
- [ ] Include saved drill settings
- [ ] Include theme preference
- [ ] Include TTS settings
- [ ] Include other safe app preferences
- [ ] Exclude current app state
- [ ] Exclude pending crash-report state
- [ ] Exclude transient runtime data
- [ ] Exclude blocked prompt attempts
- [ ] Exclude any audio/microphone data because none should exist

## 24.3 JSON Import

- [ ] Accept Hermit-Prov JSON backup file
- [ ] Validate schema version
- [ ] Reject unsupported future schema version
- [ ] Show clear future-version error
- [ ] Migrate older supported schema versions
- [ ] Import current schema version normally
- [ ] Merge imported data with existing local data
- [ ] Skip duplicate custom prompts
- [ ] Skip duplicate journal entries
- [ ] Skip duplicate practice sessions
- [ ] Skip duplicate/equivalent settings where appropriate
- [ ] Do not show review screen in v1
- [ ] Do not overwrite everything by default

## 24.4 Schema Documentation

- [ ] Document JSON schema version
- [ ] Document export metadata fields
- [ ] Document custom prompt fields
- [ ] Document journal entry fields
- [ ] Document practice history fields
- [ ] Document drill settings fields
- [ ] Document app preferences fields
- [ ] Document duplicate detection rules
- [ ] Document migration behavior
- [ ] Document unsupported future-version behavior

## 24.5 Tests

- [ ] Unit test: export includes expected data
- [ ] Unit test: export excludes current app state
- [ ] Unit test: export excludes transient data
- [ ] Unit test: export excludes blocked prompt attempts
- [ ] Unit test: import merges data
- [ ] Unit test: import skips duplicate custom prompts
- [ ] Unit test: import skips duplicate journal entries
- [ ] Unit test: import skips duplicate practice sessions
- [ ] Unit test: unsupported future schema version is rejected
- [ ] Unit test: future-version error message is clear
- [ ] Unit test: older supported schema migrates
- [ ] Widget test: Export and Import controls visible only in Settings
- [ ] Widget test: backup warning appears

---

# Milestone 25 — Privacy, About, Credits, Support, Donate

## 25.1 Privacy/About Page

- [ ] Add Privacy/About page
- [ ] Page reachable from Settings
- [ ] State no account
- [ ] State no login
- [ ] State no cloud sync
- [ ] State fully usable offline after installation
- [ ] State user data stays on-device
- [ ] State no audio recording
- [ ] State no microphone permission
- [ ] State no speech recognition
- [ ] State prompts are not sent anywhere by default
- [ ] State journal entries are not sent anywhere by default
- [ ] State practice history is not sent anywhere by default
- [ ] State optional crash reports are user-triggered only after a crash
- [ ] State crash reports include technical details and app state
- [ ] State crash reports exclude custom prompts and journal entries
- [ ] State data is local-only
- [ ] Warn users to export before deleting app or switching devices
- [ ] Include visible No Recording assurance

## 25.2 Credits and Attribution

- [ ] Add Credits section
- [ ] Link to Will Hines solo improv practice article
- [ ] Link to referenced prompt-generator inspiration sites
- [ ] Link to referenced emotion-wheel inspiration article
- [ ] Clearly state Hermit-Prov is unofficial
- [ ] Clearly state Hermit-Prov is unaffiliated with Will Hines
- [ ] Clearly state Hermit-Prov is unaffiliated with prompt-generator sites
- [ ] Clearly state Hermit-Prov is unaffiliated with emotion-wheel inspiration sources
- [ ] Keep attribution out of individual drill screens

## 25.3 Content Licensing Notes

- [ ] Document that built-in exercise descriptions must be original wording
- [ ] Document that prompt lists must be original/properly licensed/public-domain/safe-to-use
- [ ] Document that emotion-wheel labels/taxonomy must be original/properly licensed/safe-to-use
- [ ] Do not copy article text verbatim except exercise names
- [ ] Do not copy protected prompt lists
- [ ] Do not copy protected emotion wheel images/assets

## 25.4 Support Email

- [ ] Add Support / Feedback link
- [ ] Support link opens email to developer
- [ ] Email template includes app version
- [ ] Email template includes device OS
- [ ] Email template includes short issue prompt
- [ ] User can edit everything before sending
- [ ] Email does not automatically include custom prompts
- [ ] Email does not automatically include journal entries
- [ ] Email does not automatically include practice history

## 25.5 Donate Link

- [ ] Add low-key Ko-fi link
- [ ] Link opens external Ko-fi page
- [ ] Donate link appears only in Settings/About area
- [ ] No donation prompt after practice sessions
- [ ] No in-app purchase
- [ ] No subscription
- [ ] No pressure messaging

## 25.6 Tests

- [ ] Widget test: Privacy/About reachable
- [ ] Widget test: No Recording assurance appears
- [ ] Widget test: local-only warning appears
- [ ] Widget test: unaffiliated disclaimer appears
- [ ] Widget test: support link exists
- [ ] Unit/widget test: support email excludes user-created local data
- [ ] Widget test: Ko-fi link exists only in Settings/About area
- [ ] Widget test: no donation prompt after completing a drill session

---

# Milestone 26 — Optional Crash Report Prompt

## 26.1 Crash Report Architecture

- [ ] Add CrashReportProvider interface
- [ ] Add fake/no-op crash-report provider
- [ ] Add crash payload model
- [ ] Add crash payload sanitizer
- [ ] Do not send crash reports automatically
- [ ] Do not persist crash-report opt-in preference
- [ ] Crash prompt appears only after crash condition
- [ ] Real provider integration can be configured later if desired

## 26.2 Crash Prompt

- [ ] Prompt offers Send Report
- [ ] Prompt offers Don’t Send
- [ ] Prompt includes privacy note
- [ ] Privacy note says report includes technical details and app state
- [ ] Privacy note says report excludes custom prompts and journal entries
- [ ] Link Privacy/About from crash prompt if practical

## 26.3 Crash Payload Rules

- [ ] Payload may include technical crash details
- [ ] Payload may include device OS/version
- [ ] Payload may include app version
- [ ] Payload may include screen name
- [ ] Payload may include active drill
- [ ] Payload may include timer value
- [ ] Payload may include safe settings/app state
- [ ] Payload must exclude custom prompts
- [ ] Payload must exclude journal entries
- [ ] Payload must exclude audio data
- [ ] Payload must exclude microphone data
- [ ] Payload must exclude user-created content

## 26.4 Tests

- [ ] Unit test: sanitizer excludes custom prompts
- [ ] Unit test: sanitizer excludes journal entries
- [ ] Unit test: sanitizer excludes user-created content
- [ ] Unit test: sanitizer includes allowed app state
- [ ] Widget test: crash prompt shows Send Report
- [ ] Widget test: crash prompt shows Don’t Send
- [ ] Widget test: crash prompt shows privacy note
- [ ] Widget test: Don’t Send does not call provider
- [ ] Widget test: Send Report calls provider with sanitized payload
- [ ] Unit test: no persistent crash-report preference exists

---

# Milestone 27 — Accessibility, Tablet Layout, Orientation, Permissions

## 27.1 Accessibility

- [ ] Add screen reader labels for bottom navigation
- [ ] Add screen reader labels for drill cards
- [ ] Add screen reader labels for Start buttons
- [ ] Add screen reader labels for Configure buttons
- [ ] Add screen reader labels for info/help buttons
- [ ] Add screen reader labels for Pause/Resume
- [ ] Add screen reader labels for Stop/End
- [ ] Add screen reader labels for prompts
- [ ] Add screen reader labels for timers
- [ ] Add screen reader labels for progress indicators
- [ ] Ensure timer/progress state is available to screen readers
- [ ] Support large text/dynamic type
- [ ] Ensure major screens work with increased text scale
- [ ] Ensure sufficient contrast in light theme
- [ ] Ensure sufficient contrast in dark theme
- [ ] Ensure prompt text does not rely on color alone
- [ ] Ensure touch targets are comfortably sized
- [ ] Respect reduced-motion settings where applicable

## 27.2 Tablet Layout

- [ ] Add responsive layout breakpoints
- [ ] Practice home uses wider cards on tablet
- [ ] Drill controls are centered with generous spacing
- [ ] History/Journal may use split-pane layout where appropriate
- [ ] Settings uses comfortable tablet layout
- [ ] Tools screen uses tablet-friendly layout
- [ ] Do not merely scale phone UI

## 27.3 Orientation

- [ ] Phones are portrait-only
- [ ] Document tablet orientation behavior
- [ ] Confirm orientation behavior on iOS
- [ ] Confirm orientation behavior on Android

## 27.4 Permission Audit

- [ ] Confirm no microphone permission in iOS config
- [ ] Confirm no microphone permission in Android manifest
- [ ] Confirm no speech recognition permission
- [ ] Confirm no recording permission
- [ ] Confirm no push notification permission
- [ ] Confirm no local notification permission
- [ ] Confirm no contacts permission
- [ ] Confirm no location permission
- [ ] Confirm no camera permission
- [ ] Confirm network access is used only for user-triggered external actions
- [ ] Document permission audit result

## 27.5 Tests

- [ ] Widget test: key controls have semantic labels
- [ ] Widget test: large text scale does not break Practice home
- [ ] Widget test: large text scale does not break drill session screen
- [ ] Widget test: tablet width layout renders cleanly
- [ ] Static/manual test: forbidden permissions absent
- [ ] Regression test: app launches and navigation still works

---

# Milestone 28 — Final Integration and Acceptance Testing

## 28.1 End-to-End Product Flow

- [ ] Open app
- [ ] Confirm app starts on Practice tab
- [ ] Open Cat/Clock
- [ ] Start Cat/Clock with defaults
- [ ] Configure Cat/Clock
- [ ] Pause/resume Cat/Clock
- [ ] Stop Cat/Clock with confirmation
- [ ] Open Character Creation
- [ ] Start Character Creation with defaults
- [ ] Configure Character Creation
- [ ] Test Generate Prompt button on first pass
- [ ] Confirm no prompt review list
- [ ] Confirm return pass hides prompt
- [ ] Open Two-Character Scenes
- [ ] Start Two-Character Scenes with defaults
- [ ] Configure Two-Character Scenes
- [ ] Open A-to-C / Bad Idea / Initiation
- [ ] Start A-to-C with defaults
- [ ] Configure A-to-C intervals
- [ ] Open Five Line Game
- [ ] Use New Prompt button
- [ ] Enable auto-advance
- [ ] Confirm no line labels appear
- [ ] Use Prompt Generator tool
- [ ] Use Timer tool
- [ ] Use Emotion Wheel tool
- [ ] Create journal entry
- [ ] Edit journal entry
- [ ] Delete journal entry
- [ ] View History stats
- [ ] View recent 20 sessions
- [ ] Change theme
- [ ] Change TTS settings
- [ ] Export backup
- [ ] Import backup
- [ ] View Privacy/About
- [ ] Open Support email
- [ ] Open Ko-fi link

## 28.2 Prohibited Feature Audit

- [ ] No accounts
- [ ] No login
- [ ] No cloud sync
- [ ] No audio recording
- [ ] No microphone permission
- [ ] No speech recognition
- [ ] No push notifications
- [ ] No local reminder notifications
- [ ] No ads
- [ ] No subscriptions
- [ ] No in-app purchases
- [ ] No AI-generated prompts
- [ ] No AI coaching
- [ ] No AI feedback
- [ ] No leaderboards
- [ ] No badges
- [ ] No public/social streaks
- [ ] No nagging reminders

## 28.3 Cleanup

- [ ] Remove dead code
- [ ] Remove unused placeholders
- [ ] Remove orphan screens
- [ ] Remove fake drill if still present
- [ ] Confirm every screen is reachable through intended navigation
- [ ] Confirm no debug-only copy remains
- [ ] Keep only intentionally marked placeholder prompt content if final content is not ready
- [ ] Keep only intentionally marked placeholder emotion taxonomy if final taxonomy is not ready
- [ ] Run formatter
- [ ] Run analyzer/linter
- [ ] Run full test suite
- [ ] Fix all test failures

## 28.4 Developer Documentation

- [ ] Document local data schema
- [ ] Document repository architecture
- [ ] Document export/import JSON schema
- [ ] Document schema versioning
- [ ] Document migration behavior
- [ ] Document duplicate skipping rules
- [ ] Document prompt validation rules
- [ ] Document built-in prompt content requirements
- [ ] Document how to replace placeholder prompt lists
- [ ] Document emotion wheel taxonomy/content requirements
- [ ] Document crash-report provider abstraction
- [ ] Document permission audit
- [ ] Document manual QA checklist
- [ ] Document known limitations for v1

## 28.5 Final Acceptance Criteria

- [ ] App is internally coherent
- [ ] App can be used offline after installation
- [ ] All five drills are usable
- [ ] Drill settings persist locally
- [ ] Prompt system works with built-in and custom prompts
- [ ] Custom prompt validation is on-device
- [ ] Hands-Free Mode works across all drills
- [ ] Practice History logs qualifying sessions silently
- [ ] Journal works
- [ ] Tools section works
- [ ] Settings section works
- [ ] Export/import works
- [ ] Privacy/About is clear
- [ ] No forbidden permissions exist
- [ ] Accessibility basics are implemented
- [ ] Tablet layouts are intentional
- [ ] Full test suite passes
- [ ] Ready for content/design/QA finalization

---

# Separate Content and Design Work

These are not core engineering blockers unless you decide to include them in the same contract.

## Prompt List Content

- [ ] Research prompt-list sources and licensing
- [ ] Create robust Objects list
- [ ] Create robust Locations list
- [ ] Create robust Relationships list
- [ ] Create robust Occupations list
- [ ] Create robust Emotions list
- [ ] Create robust Activities list
- [ ] Ensure no specific brands
- [ ] Ensure no celebrities
- [ ] Ensure no copyrighted fictional character names
- [ ] Ensure no slurs
- [ ] Ensure no explicitly sexual content
- [ ] Ensure no hateful content
- [ ] Allow mildly edgy adult-life prompts
- [ ] Review prompt list for duplicates
- [ ] Review prompt list for spelling/format consistency
- [ ] Convert prompt lists into app seed format
- [ ] Add content version metadata if useful

## Emotion Wheel Content

- [ ] Design original emotion wheel taxonomy
- [ ] Confirm taxonomy does not copy protected source text
- [ ] Confirm no protected images/assets are used
- [ ] Create broad emotion groups
- [ ] Create specific emotion labels
- [ ] Review labels for clarity
- [ ] Convert taxonomy into app seed format

## Visual Design

- [ ] Decide final color palette
- [ ] Decide typography direction
- [ ] Design app icon
- [ ] Decide whether to include subtle hermit-crab mascot
- [ ] Design mascot if included
- [ ] Create splash screen if needed
- [ ] Review light mode
- [ ] Review dark mode
- [ ] Review tablet layouts
- [ ] Review accessibility contrast

## App Store / Legal / Support

- [ ] Draft privacy policy
- [ ] Host privacy policy at public URL
- [ ] Draft support page or support contact page
- [ ] Decide if terms are needed
- [ ] Prepare Apple App Privacy details
- [ ] Prepare Google Play Data Safety form
- [ ] Prepare app store screenshots
- [ ] Prepare app description
- [ ] Prepare keywords
- [ ] Prepare support email address
- [ ] Prepare Ko-fi URL
- [ ] Prepare credits/attribution links
- [ ] Confirm unaffiliated disclaimers
- [ ] Confirm no misleading references to inspiration sources

---

# Manual QA Checklist

Use this before any test release.

## Installation and Offline Use

- [ ] Install app on iOS device
- [ ] Install app on Android device
- [ ] Launch app without creating account
- [ ] Put device in airplane mode
- [ ] Confirm Practice home works offline
- [ ] Confirm all drills work offline
- [ ] Confirm Prompt Generator works offline
- [ ] Confirm Timer works offline
- [ ] Confirm Emotion Wheel works offline
- [ ] Confirm Journal works offline
- [ ] Confirm History works offline
- [ ] Confirm Settings works offline
- [ ] Confirm external links fail gracefully or wait for connectivity

## Drill QA

- [ ] Cat/Clock generates two prompts
- [ ] Cat/Clock runs 3-minute default speaking segment
- [ ] Cat/Clock runs 30-second regroup
- [ ] Cat/Clock loops
- [ ] Character Creation defaults to 2 characters
- [ ] Character Creation cycles Character 1, Character 2, Return 1, Return 2
- [ ] Character Creation Generate Prompt appears only on first passes
- [ ] Character Creation hides prompt on return passes
- [ ] Two-Character Scenes defaults to 90 seconds
- [ ] Two-Character Scenes has 30-second regroup
- [ ] Two-Character Scenes loops
- [ ] A-to-C defaults to 30-second prompt changes
- [ ] A-to-C has no regroup
- [ ] Five Line Game defaults to prompt only
- [ ] Five Line Game New Prompt button works
- [ ] Five Line Game auto-advance works when enabled

## Hands-Free QA

- [ ] Hands-Free Mode is off by default
- [ ] Cat/Clock reads prompt pair
- [ ] Cat/Clock regroup is silent
- [ ] Two-Character Scenes reads prompt
- [ ] A-to-C reads each new prompt
- [ ] A-to-C 30-second interval has no timer announcements
- [ ] Five Line Game reads prompt
- [ ] Character Creation first pass reads character and prompt
- [ ] Character Creation return pass reads only character label
- [ ] Pause suppresses TTS
- [ ] Stop stops TTS

## Privacy and Permission QA

- [ ] App never requests microphone permission
- [ ] App never requests speech recognition permission
- [ ] App never requests notification permission
- [ ] App never requests camera permission
- [ ] App never requests location permission
- [ ] App does not record audio
- [ ] Privacy/About states no recording
- [ ] Privacy/About states local-only data
- [ ] Privacy/About explains optional crash reports
- [ ] Crash prompt, if triggered, has Send Report / Don’t Send
- [ ] Crash prompt explains excluded user content

## Backup QA

- [ ] Create custom prompt
- [ ] Create journal entry
- [ ] Complete drill session
- [ ] Change drill setting
- [ ] Change theme
- [ ] Change TTS setting
- [ ] Export JSON backup
- [ ] Inspect JSON for expected fields
- [ ] Confirm JSON excludes current app state
- [ ] Confirm JSON excludes crash-report state
- [ ] Import same backup
- [ ] Confirm duplicates are skipped
- [ ] Reset All Data
- [ ] Import backup
- [ ] Confirm data is restored

---

# Definition of Done

Hermit-Prov v1 is done when:

- [ ] All core v1 features are implemented
- [ ] All no-goals are still absent
- [ ] All automated tests pass
- [ ] Manual QA checklist passes
- [ ] App runs on iOS and Android
- [ ] App is usable offline
- [ ] No prohibited permissions are requested
- [ ] Export/import works
- [ ] Privacy/About is complete
- [ ] App store support/privacy materials are ready
- [ ] Final prompt content is either complete or clearly marked as placeholder
- [ ] Final emotion wheel content is either complete or clearly marked as placeholder
- [ ] Codebase has no orphaned major features
- [ ] Developer docs are sufficient for maintenance
