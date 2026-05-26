# Hermit Prov TODO Checklist

This checklist is based on the **Hermit Prov Developer Handoff Spec** and the implementation blueprint/codegen prompt sequence.

Use it as a living project tracker. The intent is to build Hermit Prov incrementally, test-first, with every feature wired into the app as it is implemented.

---

## Status Key

- `[ ]` Not started
- `[~]` In progress
- `[x]` Done
- `[!]` Deferred by choice, not forgotten (see linked issue)

---

## Project Principles Checklist

Keep these constraints visible during the entire project.

- [x] App is named **Hermit Prov**
- [x] Flutter is preferred, but another cross-platform framework is acceptable if it preserves the spec
- [x] App supports iOS and Android
- [x] App supports phones and tablets
- [x] Phones are portrait-only
- [!] Tablets use tablet-friendly layouts, not merely scaled phone layouts (tablet-specific layouts deferred, see issue #5)
- [x] App is English-only for v1
- [x] App opens directly to Practice / Choose Your Drill
- [x] No onboarding flow in v1
- [x] All user data stays local unless the user explicitly exports it or sends a crash report
- [x] App is fully usable offline after installation
- [x] No accounts
- [x] No login
- [x] No cloud sync
- [x] No audio recording
- [x] No microphone permission
- [x] No speech recognition
- [x] No push notifications
- [x] No local reminder notifications
- [x] No social features
- [x] No multiplayer
- [x] No ads
- [x] No subscriptions
- [x] No in-app purchases
- [x] Low-key external Ko-fi donation link only
- [x] No AI-generated prompts
- [x] No AI coaching
- [x] No AI feedback
- [x] No badges
- [x] No leaderboards
- [x] No public streaks
- [x] No nagging reminders
- [x] Streaks are quiet local personal stats only

---

# Milestone 0: Repository and Project Setup

## 0.1 Repository Setup

- [x] Create project repository
- [x] Add README.md
- [ ] Add LICENSE file if applicable
- [x] Add `.gitignore`
- [x] Add basic project structure
- [ ] Add issue templates if desired
- [ ] Add pull request template if desired
- [ ] Add contribution notes if this will be open source
- [x] Add initial manual QA checklist document
- [x] Add this `todo.md` checklist to the repo

## 0.2 Flutter Project Setup

- [x] Create Flutter app
- [ ] Confirm app runs on iOS simulator
- [x] Confirm app runs on Android emulator
- [x] Confirm app runs in debug mode
- [ ] Confirm app builds in release mode locally
- [x] Set app display name to **Hermit Prov**
- [x] Configure package/application IDs
- [x] Add app versioning strategy
- [x] Add linting configuration
- [x] Add formatting command/process
- [x] Add test command/process

## 0.3 Initial Dependency Decisions

- [x] Choose state management approach: StatefulWidget + InheritedWidget (AppServices DI)
- [x] Choose local persistence approach: Drift (SQLite)
- [x] Choose routing/navigation approach: Navigator.push (no routing package)
- [x] Choose text-to-speech package: flutter_tts
- [x] Choose share/file picker packages for export/import: share_plus + file_picker
- [x] Choose URL/email launcher package: url_launcher
- [x] Choose crash-report provider or decide on no-op shell for v1 development: no-op shell with opt-in dialog
- [ ] Document dependency choices in README or developer docs

## 0.4 Test Infrastructure

- [x] Confirm unit tests run
- [x] Confirm widget tests run
- [x] Add test helpers
- [x] Add fake clock or timer helper: DrillSessionController.tick() for deterministic testing
- [x] Add fake repositories: AppServices.withInMemory()
- [x] Add fake TTS service
- [x] Add fake crash-report provider
- [ ] Add test data builders/factories
- [ ] Add CI test command if using CI

---

# Milestone 1: App Shell and Navigation

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

# Milestone 2: Practice Home / Choose Your Drill

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

# Milestone 3: Domain Models and Defaults

## 3.1 Core Enums and IDs

- [x] Add `DrillId.catClock`
- [x] Add `DrillId.characterCreation`
- [x] Add `DrillId.twoCharacterScenes`
- [x] Add `DrillId.atoC`
- [x] Add `DrillId.fiveLineGame`
- [x] Add `PromptCategory.objects`
- [x] Add `PromptCategory.locations`
- [x] Add `PromptCategory.relationships`
- [x] Add `PromptCategory.occupations`
- [x] Add `PromptCategory.emotions`
- [x] Add `PromptCategory.activities`
- [x] Add `PromptCategory.genre`
- [x] Add `PromptCategory.events`
- [x] Add theme preference enum: system/light/dark
- [x] Define word bucket as all prompt categories combined
- [x] Confirm word bucket is not a separate persisted prompt category

## 3.2 Prompt Models

- [x] Add `BuiltInPrompt` model
- [x] Add `CustomPrompt` model
- [x] Add prompt ID field
- [x] Add prompt category field
- [x] Add prompt text field
- [x] Add created timestamp for custom prompts
- [x] Add updated timestamp for custom prompts
- [ ] Add serialization/deserialization if needed
- [ ] Add equality behavior if needed

## 3.3 Drill Settings Models

- [x] Add base `DrillSettings` model or per-drill settings models
- [x] Add Cat/Clock settings
- [x] Add Character Creation settings
- [x] Add Two-Character Scenes settings
- [x] Add A-to-C settings
- [x] Add Five Line Game settings
- [x] Add saved prompt category selections
- [x] Add Hands-Free Mode flag per drill/session configuration
- [x] Add default factory for every drill

## 3.4 Drill Defaults

- [x] Cat/Clock default speaking duration is 3 minutes
- [x] Cat/Clock default regroup duration is 30 seconds
- [x] Cat/Clock default prompt source is word + word
- [x] Cat/Clock loops until stopped
- [x] Character Creation default character count is 2
- [x] Character Creation default segment duration is 60 seconds
- [x] Character Creation allowed segment durations are 60/90/120 seconds
- [x] Character Creation default prompt source is word bucket
- [x] Character Creation has finite cycle, no indefinite loop
- [x] Two-Character Scenes default scene duration is 90 seconds
- [x] Two-Character Scenes default regroup duration is 30 seconds
- [x] Two-Character Scenes default prompt source is word bucket
- [x] Two-Character Scenes loops until stopped
- [x] A-to-C default interval is 30 seconds
- [x] A-to-C allowed intervals are 15/30/45/60 seconds
- [x] A-to-C default prompt source is word bucket
- [x] A-to-C loops until stopped
- [x] Five Line Game default is prompt only
- [x] Five Line Game auto-advance default is off
- [x] Five Line Game allowed auto-advance intervals are 30/60/90 seconds
- [x] Five Line Game default prompt source is word bucket

## 3.5 Practice History and Journal Models

- [x] Add `PracticeSession` model
- [x] PracticeSession stores drill ID/name
- [x] PracticeSession stores date/time
- [x] PracticeSession stores duration
- [x] PracticeSession does not store prompts used
- [x] PracticeSession does not store settings used
- [x] Add `JournalEntry` model
- [x] JournalEntry stores date/createdAt
- [x] JournalEntry stores updatedAt
- [x] JournalEntry stores optional drill tag
- [x] JournalEntry stores body text
- [x] JournalEntry does not require a linked practice session

## 3.6 App Preferences Model

- [x] Add `AppPreferences` model
- [x] Add theme preference
- [x] Add TTS voice setting
- [x] Add TTS speaking rate setting
- [x] Add any other safe app-level preference fields
- [x] Do not add persistent crash-report opt-in preference

## 3.7 Repository Interfaces

- [x] Add `PromptRepository` interface
- [x] Add `DrillSettingsRepository` interface
- [x] Add `PracticeHistoryRepository` interface
- [x] Add `JournalRepository` interface
- [x] Add `AppPreferencesRepository` interface
- [x] Keep repository interfaces independent of a database package
- [x] Add clear method contracts
- [x] Add error/result handling strategy

## 3.8 Tests

- [x] Unit test: word bucket expands to all eight categories
- [x] Unit test: Cat/Clock defaults
- [x] Unit test: Character Creation defaults
- [x] Unit test: Two-Character Scenes defaults
- [x] Unit test: A-to-C defaults
- [x] Unit test: Five Line Game defaults
- [x] Unit test: Character Creation duration options
- [x] Unit test: A-to-C interval options
- [x] Unit test: Five Line Game interval options
- [x] Unit test: PracticeSession excludes prompts/settings
- [x] Unit test: AppPreferences default theme is system

---

# Milestone 4: In-Memory Repositories and Seed Prompts

## 4.1 In-Memory Repositories

- [x] Implement in-memory PromptRepository
- [x] Implement in-memory DrillSettingsRepository
- [x] Implement in-memory PracticeHistoryRepository
- [x] Implement in-memory JournalRepository
- [x] Implement in-memory AppPreferencesRepository
- [x] Wire repositories into app using chosen dependency pattern
- [x] Ensure repositories can be swapped later for durable local persistence
- [x] Ensure tests can inject fake/in-memory repositories

## 4.2 Seed Prompt System

- [x] Add seed prompt source
- [x] Add placeholder built-in Object prompts
- [x] Add placeholder built-in Location prompts
- [x] Add placeholder built-in Relationship prompts
- [x] Add placeholder built-in Occupation prompts
- [x] Add placeholder built-in Emotion prompts
- [x] Add placeholder built-in Activity prompts
- [x] Clearly mark seed prompts as placeholder content
- [x] Ensure final robust prompt lists are documented as separate content task
- [x] Built-in prompts are read-only
- [x] Custom prompts are stored separately

## 4.3 Repository Behavior

- [x] Built-in prompts load by category
- [x] Built-in prompts load into word bucket
- [x] Custom prompts can be added
- [x] Custom prompts can be listed by category
- [x] Built-in prompts cannot be edited
- [x] Built-in prompts cannot be deleted
- [x] Drill settings repository returns defaults if no saved settings exist
- [x] Drill settings repository returns saved settings after update
- [x] App preferences repository returns defaults if none saved

## 4.4 Tests

- [x] Repository test: built-in prompts load for every category
- [x] Repository test: custom prompts are separate from built-in prompts
- [x] Repository test: built-in prompts cannot be edited
- [x] Repository test: built-in prompts cannot be deleted
- [x] Repository test: drill settings defaults are returned
- [x] Repository test: saved drill settings override defaults
- [x] Repository test: app preferences defaults are returned
- [x] Repository test: saved app preferences are returned

---

# Milestone 5: Prompt Picker and Custom Prompt Validation

## 5.1 Prompt Picker

- [x] Add PromptPicker service
- [x] Pick random prompt from one category
- [x] Pick random prompt from multiple categories
- [x] Pick random prompt from word bucket
- [x] Include built-in prompts automatically
- [x] Include custom prompts automatically
- [x] Mix built-in and custom prompts without extra user setting
- [x] Do not implement built-in-only/custom-only/both filters
- [x] Handle empty category gracefully
- [x] Handle empty prompt pool gracefully

## 5.2 Custom Prompt Validator

- [x] Add CustomPromptValidator
- [x] Validation happens entirely on-device
- [x] No network calls
- [x] Broadly block slurs
- [x] Narrowly block clearly explicit/graphic sexual content
- [x] Allow non-graphic adult-life prompts
- [x] Allow “bad date”
- [x] Allow “affair”
- [x] Allow “crush”
- [x] Allow “flirting”
- [x] Allow “awkward hookup”
- [x] Allow “divorce”
- [x] Return generic validation failure only
- [x] Do not expose specific blocked reason to user
- [x] Do not log blocked attempts
- [x] Do not save rejected prompts

## 5.3 Tests

- [x] Unit test: pick from single category
- [x] Unit test: pick from multiple categories
- [x] Unit test: pick from word bucket
- [x] Unit test: built-in and custom prompts are both eligible
- [x] Unit test: empty category behavior
- [x] Unit test: slur blocking
- [x] Unit test: explicit/graphic sexual content blocking
- [x] Unit test: allowed adult-life prompts pass
- [x] Repository test: rejected prompt is not saved
- [x] Repository test: rejected prompt is not logged

---

# Milestone 6: Custom Prompt Management UI

## 6.1 Custom Prompt Screen

- [x] Add Custom Prompts screen
- [x] Make screen reachable from Tools or Prompt Generator
- [x] Show custom prompts
- [x] Show prompt category for each custom prompt
- [x] Allow category selection when adding prompt
- [x] Allow category selection when editing prompt
- [x] Keep UI simple and accessible

## 6.2 Custom Prompt CRUD

- [x] Add custom prompt
- [x] Edit custom prompt
- [x] Delete custom prompt
- [x] Confirm deletion if appropriate
- [x] Validate custom prompt before saving
- [x] Show simple generic error if blocked
- [x] Do not show reason for blocked prompt
- [x] Do not log blocked attempt
- [x] Built-in prompts are not editable
- [x] Built-in prompts are not deletable
- [x] Built-in prompts are not disableable

## 6.3 Tests

- [x] Widget test: Custom Prompts screen is reachable
- [x] Widget test: valid custom prompt can be added
- [x] Widget test: custom prompt can be edited
- [x] Widget test: custom prompt can be deleted
- [x] Widget test: blocked prompt shows generic error
- [x] Widget test: blocked prompt is not listed afterward
- [x] Widget test: built-in prompts are not editable through this screen
- [x] Widget test: built-in prompts are not deletable through this screen

---

# Milestone 7: Tools: Standalone Prompt Generator

## 7.1 Tools Screen

- [x] Replace Tools placeholder with real Tools screen
- [x] Add Prompt Generator item
- [x] Add Timer placeholder item
- [x] Add Emotion Wheel placeholder item
- [x] Add Practice Journal placeholder/link item
- [x] Tools remains reachable from Practice home card
- [x] Tools is not in bottom navigation

## 7.2 Prompt Generator Tool

- [x] Add Prompt Generator screen
- [x] Allow selecting one prompt category
- [x] Allow selecting multiple prompt categories
- [x] Allow selecting word bucket
- [x] Default selection is word bucket
- [x] Add New Prompt button
- [x] Display generated prompt clearly
- [x] Use built-in and custom prompts automatically
- [x] Handle no prompt available gracefully

## 7.3 Prompt Generator Auto-Advance

- [x] Add optional auto-advance toggle
- [x] Auto-advance default is off
- [x] Add 15-second interval option
- [x] Add 30-second interval option
- [x] Add 45-second interval option
- [x] Add 60-second interval option
- [x] Auto-advance refreshes prompt on selected interval
- [x] Auto-advance stops when leaving screen
- [x] Auto-advance pauses/disposes cleanly when widget is disposed

## 7.4 Tests

- [x] Widget test: Tools screen shows Prompt Generator
- [x] Widget test: Tools screen shows Timer placeholder
- [x] Widget test: Tools screen shows Emotion Wheel placeholder
- [x] Widget test: Tools screen shows Practice Journal item
- [x] Widget test: Prompt Generator is reachable
- [x] Widget test: New Prompt displays prompt
- [x] Widget test: category selection changes eligible prompt pool
- [x] Widget/unit test: auto-advance changes prompt
- [x] Widget/unit test: auto-advance is cancelled when leaving screen

---

# Milestone 8: Reusable Timer and Session Engine

## 8.1 Timer Segment Model

- [x] Add timer segment model
- [x] Segment has ID/type
- [x] Segment has duration
- [x] Segment can have display label
- [x] Segment can have prompt payload
- [x] Segment can indicate regroup/rest/speaking/prompt interval/character pass
- [x] Segment model is independent of widgets

## 8.2 Drill Session Controller

- [x] Add DrillSessionController or equivalent state machine
- [x] Support start
- [x] Support manual/fake tick for tests
- [x] Support pause
- [x] Support resume
- [x] Support stop request
- [x] Support segment completion
- [x] Support finite session completion
- [x] Support looping session sequences
- [x] Track current segment
- [x] Track remaining segment time
- [x] Track elapsed session time
- [x] Track whether paused
- [x] Track whether complete
- [x] Track whether stopped
- [x] Avoid depending on real time for unit tests

## 8.3 Progress Calculation

- [x] Add current segment progress
- [x] Add current rep/cycle progress where appropriate
- [x] Progress works for finite cycles
- [x] Progress works for looping cycles
- [x] Progress resets per current rep/cycle for looping drills
- [x] Progress does not attempt unknown total session progress for indefinite loops

## 8.4 Pause/Resume Behavior

- [x] Pause freezes remaining time
- [x] Pause freezes prompt/segment changes
- [x] Resume continues from same state
- [x] Pause does not complete segments
- [x] Resume does not restart current segment

## 8.5 Tests

- [x] Unit test: countdown decreases with ticks
- [x] Unit test: segment completion advances to next segment
- [x] Unit test: looping sequence restarts after final segment
- [x] Unit test: finite sequence completes after final segment
- [x] Unit test: pause freezes time
- [x] Unit test: pause freezes segment changes
- [x] Unit test: resume continues correctly
- [x] Unit test: progress calculation for simple segment
- [x] Unit test: progress calculation for looping cycle
- [x] Unit test: progress calculation for finite cycle

---

# Milestone 9: Reusable Drill UI Shell

## 9.1 Drill Start Screen Pattern

- [x] Replace drill placeholders with reusable start screen
- [x] Show drill name
- [x] Show short description/subtitle
- [x] Show Start button
- [x] Show Configure button
- [x] Show info/help button
- [x] Start uses saved drill settings
- [x] Start uses defaults if no saved settings exist

## 9.2 Configure Screen Pattern

- [x] Add reusable configure screen structure
- [x] Allow drill-specific settings sections
- [x] Save settings when user starts from configuration
- [x] Persist changed settings locally
- [x] Return to start screen when appropriate
- [x] Keep configuration UI simple

## 9.3 Active Drill Session Shell

- [x] Add reusable active drill session screen
- [x] Show large countdown timer when applicable
- [x] Show circular progress ring when applicable
- [x] Show prompt/label display area
- [x] Add Pause/Resume button
- [x] Add Stop/End button
- [x] Stop/End returns to idle; back gesture shows confirmation when session is active
- [x] Confirming back/leave returns to drill start screen
- [x] Pause freezes session controller
- [x] Resume continues session controller

## 9.4 Temporary Fake Drill Integration

- [x] Wire one simple fake/test drill through shell
- [x] Confirm session shell works before building real drills
- [x] Remove fake drill once real drill is integrated
- [x] Ensure no orphan fake screen remains

## 9.5 Tests

- [x] Widget test: drill start shows Start, Configure, info/help
- [x] Widget test: Configure can update simple saved setting
- [x] Widget test: Start launches session shell
- [x] Widget test: Pause changes to Resume
- [x] Widget/unit test: pause freezes displayed timer
- [x] Widget test: Stop resets to idle; back gesture shows leave confirmation
- [x] Widget test: confirming leave returns to start screen
- [x] Test no fake drill remains after real drills are wired

---

# Milestone 10: Drill: Cat/Clock

## 10.1 Cat/Clock Flow

- [x] Generate two prompts at start of each rep
- [x] Speaking segment defaults to 3 minutes
- [x] Regroup segment defaults to 30 seconds
- [x] Speaking segment shows both prompts
- [x] Regroup segment shows countdown
- [x] After regroup, generate new prompt pair
- [x] Continue until user manually stops
- [x] Pause/resume works
- [x] Stop resets to idle; back gesture protected

## 10.2 Cat/Clock Configuration

- [x] Configure speaking duration
- [x] Configure regroup duration
- [x] Configure prompt 1 category source
- [x] Configure prompt 2 category source
- [x] Default prompt 1 source is [objects] (matches CatClockSettings.prompt1Categories default)
- [x] Default prompt 2 source is [objects] (matches CatClockSettings.prompt2Categories default)
- [x] Allow category combinations such as object + location
- [x] Save configuration locally
- [x] Start uses saved configuration

## 10.3 Cat/Clock UI

- [x] Start screen uses reusable drill start pattern
- [x] Configure screen uses reusable configure pattern
- [x] Session screen uses reusable session shell
- [x] Show both prompts prominently
- [x] Show countdown
- [x] Show circular progress for current rep/cycle
- [x] Keep UI uncluttered
- [x] Do not show excessive instructions during drill

## 10.4 Tests

- [x] Unit test: Cat/Clock builds speaking + regroup sequence
- [x] Unit test: Cat/Clock sequence loops
- [x] Unit test: prompts regenerate each speaking rep
- [x] Widget test: Start launches with two prompts
- [x] Widget test: Configure saves speaking duration
- [x] Widget test: Configure saves regroup duration
- [x] Widget test: Configure saves prompt categories
- [x] Widget test: Pause/Resume works
- [x] Widget test: Stop resets to idle

---

# Milestone 11: Drill: Two-Character Scenes

## 11.1 Two-Character Scenes Flow

- [x] Generate one prompt
- [x] Scene timer defaults to 90 seconds
- [x] Regroup timer defaults to 30 seconds
- [x] After regroup, generate new prompt
- [x] Continue until user manually stops
- [x] Pause/resume works
- [x] Stop resets to idle; back gesture protected

## 11.2 Two-Character Scenes Configuration

- [x] Configure scene duration
- [x] Configure regroup duration
- [x] Configure prompt category source
- [x] Default prompt source is word bucket
- [x] Save configuration locally
- [x] Start uses saved configuration

## 11.3 Two-Character Scenes UI

- [x] Show prompt
- [x] Show countdown
- [x] Show circular progress for current rep/cycle
- [x] Do not display which character is speaking
- [x] Do not include character-switching labels
- [x] Keep drill screen simple

## 11.4 Tests

- [x] Unit test: sequence is prompt scene + regroup loop
- [x] Unit test: prompt regenerates after regroup
- [x] Widget test: Start launches with one prompt
- [x] Widget test: no character speaker labels appear
- [x] Widget test: Configure saves scene duration
- [x] Widget test: Configure saves regroup duration
- [x] Widget test: Configure saves category settings
- [x] Widget test: Pause/Resume works
- [x] Widget test: Stop resets to idle

---

# Milestone 12: Drill: A-to-C / Bad Idea / Initiation

## 12.1 A-to-C Flow

- [x] Treat as one drill with full name
- [x] Show one prompt
- [x] Default prompt interval is 30 seconds
- [x] Prompt changes automatically each interval
- [x] Repeat rapid-fire until user stops
- [x] No regroup segment
- [x] Pause/resume works
- [x] Stop resets to idle; back gesture protected

## 12.2 A-to-C Configuration

- [x] Configure interval
- [x] Allow 15 seconds
- [x] Allow 30 seconds
- [x] Allow 45 seconds
- [x] Allow 60 seconds
- [x] Configure prompt category source
- [x] Default prompt source is word bucket
- [x] Save configuration locally
- [x] Start uses saved configuration

## 12.3 A-to-C UI

- [x] Show current prompt
- [x] Show countdown for current interval
- [x] Show circular progress for current interval/rep
- [x] Keep screen uncluttered
- [x] Do not split into separate A-to-C, Bad Idea, and Initiation drills

## 12.4 Tests

- [x] Unit test: default interval is 30 seconds
- [x] Unit test: allowed intervals are 15/30/45/60
- [x] Unit test: prompt changes each interval
- [x] Unit test: flow loops until stopped
- [x] Widget test: Start launches with one prompt
- [x] Widget test: Configure saves interval
- [x] Widget test: Configure saves category settings
- [x] Widget test: Pause/Resume freezes prompt changes
- [x] Widget test: Stop resets to idle

---

# Milestone 13: Drill: Five Line Game

## 13.1 Five Line Game Default Flow

- [x] Show one prompt
- [x] No timer by default
- [x] Show New Prompt button
- [x] Tapping New Prompt generates another prompt
- [x] Prompt source defaults to word bucket
- [x] No line tracking
- [x] No speaking detection

## 13.2 Forbidden Five Line UI Elements

- [x] Do not show Line 1
- [x] Do not show Line 2
- [x] Do not show Line 3
- [x] Do not show Line 4
- [x] Do not show Line 5
- [x] Do not show initiation/response/heightening/turn/button labels
- [x] Do not attempt to know which line is being spoken

## 13.3 Optional Auto-Advance

- [x] Auto-advance default is off
- [x] Allow 30-second interval
- [x] Allow 60-second interval
- [x] Allow 90-second interval
- [x] If enabled, show countdown/progress
- [x] If enabled, generate prompt at each interval
- [x] Pause/resume applies only when auto-advance is on
- [x] Save auto-advance settings locally

## 13.4 Configuration

- [x] Configure prompt category source
- [x] Configure auto-advance on/off
- [x] Configure auto-advance interval
- [x] Save configuration locally
- [x] Start uses saved configuration

## 13.5 Tests

- [x] Widget test: default screen shows prompt and New Prompt
- [x] Widget test: default screen shows no timer
- [x] Widget test: New Prompt changes prompt
- [x] Widget test: no Line 1–5 labels appear
- [x] Widget test: no structural scene labels appear
- [x] Widget/unit test: auto-advance changes prompts
- [x] Widget test: Configure saves category settings
- [x] Widget test: Configure saves auto-advance settings
- [x] Widget test: Pause/Resume works when auto-advance is on

---

# Milestone 14: Character Creation Cycle Logic

## 14.1 Cycle Builder

- [x] Add CharacterCreationCycleBuilder
- [x] Default character count is 2
- [x] Maximum character count is 5
- [x] Allowed segment durations are 60/90/120 seconds
- [x] Each character has first pass
- [x] Each character has return pass
- [x] Cycle is finite
- [x] Cycle does not loop by default
- [x] Total duration scales with characters × 2 × segment duration

## 14.2 Cycle Ordering

- [x] 2-character cycle: Character 1
- [x] 2-character cycle: Character 2
- [x] 2-character cycle: Return to Character 1
- [x] 2-character cycle: Return to Character 2
- [x] 5-character cycle includes Character 1–5 first passes
- [x] 5-character cycle includes Return to Character 1–5
- [x] Segment metadata identifies first pass vs return pass
- [x] Segment metadata identifies character number

## 14.3 Tests

- [x] Unit test: default 2-character cycle
- [x] Unit test: 5-character cycle
- [x] Unit test: total duration calculation
- [x] Unit test: allowed segment durations
- [x] Unit test: invalid segment duration behavior
- [x] Unit test: invalid character count behavior
- [x] Unit test: return-pass labels
- [x] Unit test: first-pass metadata
- [x] Unit test: return-pass metadata

---

# Milestone 15: Character Creation UI

## 15.1 Character Creation Configuration

- [x] Configure number of characters
- [x] Default number of characters is 2
- [x] Max number of characters is 5
- [x] Configure segment duration
- [x] Segment duration options are 60/90/120 seconds
- [x] Configure prompt category source
- [x] Default prompt source is word bucket
- [x] Save settings locally
- [x] Start uses saved configuration

## 15.2 Normal Mode Session

- [x] Show “Character N” during first pass
- [x] Show “Return to Character N” during return pass
- [x] Show countdown
- [x] Show circular progress for cycle
- [x] Show Pause/Resume
- [x] Show Stop/End; back gesture protected while active
- [x] Session ends after full cycle
- [x] Return to Start screen after cycle completes

## 15.3 Normal Mode Prompt Generation

- [x] Prompt generation is manual and optional
- [x] Show Generate Prompt button only on first passes
- [x] Generate and display prompt if user taps button
- [x] Do not show Generate Prompt button on return passes
- [x] Do not show original prompt on return passes
- [x] Do not provide Character List
- [x] Do not provide review button
- [x] Remembering is part of the drill

## 15.4 Tests

- [x] Widget test: default setup launches Character 1
- [x] Widget test: Generate Prompt appears on first pass
- [x] Widget test: Generate Prompt does not appear on return pass
- [x] Widget test: generated prompt appears during first pass
- [x] Widget test: return pass shows “Return to Character N”
- [x] Widget test: return pass does not show original prompt
- [x] Widget test: no Character List button exists
- [x] Widget test: no review button exists
- [x] Widget test: session completes after final return pass
- [x] Widget test: Configure saves character count
- [x] Widget test: Configure saves segment duration
- [x] Widget test: Configure saves prompt category source

---

# Milestone 16: Text-to-Speech Service and Global Settings

## 16.1 TTS Service

- [x] Add TtsService interface
- [x] Add speak method
- [x] Add stop method
- [x] Add speaking rate support
- [x] Add fake TTS service for tests
- [x] Add real TTS implementation (flutter_tts)
- [x] Ensure no microphone permission is added
- [x] Ensure no speech recognition permission is added
- [x] Ensure no recording permission is added

## 16.2 Global TTS Preferences

- [x] Add TTS speaking rate to AppPreferences
- [x] Persist TTS settings locally
- [x] TTS settings apply globally
- [x] Hands-Free Mode is not an app-wide default
- [x] Hands-Free Mode remains per drill/session configuration

## 16.3 Settings UI

- [x] Add Text-to-Speech section to Settings
- [x] Show speaking rate setting
- [x] Allow changing speaking rate
- [x] Save TTS settings
- [x] Keep settings UI accessible

## 16.4 Tests

- [x] Unit test: fake TTS captures spoken text
- [x] Repository test: TTS rate setting persists
- [x] Widget test: TTS settings screen is reachable
- [x] Widget test: changing speaking rate saves preference
- [ ] Static/manual check: no microphone permission
- [ ] Static/manual check: no speech-recognition permission

---

# Milestone 17: Hands-Free Announcement Policy

## 17.1 General Policy

- [x] Add HandsFreeAnnouncementPolicy
- [x] For non-character prompt segments, read prompt aloud when it appears
- [x] Prompt reading replaces “begin”
- [x] Do not announce “begin” when prompt is read
- [x] Segments longer than 30 seconds get timer announcements
- [x] Announce “30 seconds” for segments longer than 30 seconds
- [x] Announce “10 seconds” for segments longer than 30 seconds
- [x] Announce “time” for segments longer than 30 seconds
- [x] Exactly 30-second segments get no timer announcements
- [x] If exactly 30-second segment has prompt, read only prompt
- [x] If exactly 30-second segment has no prompt, stay silent
- [x] Regroup segments stay silent
- [x] Paused state suppresses announcements
- [x] Resume continues policy from current state

## 17.2 Character Creation Policy

- [x] In Hands-Free Mode, generate prompt automatically on first passes
- [x] First pass announcement is “Character N: prompt”
- [x] Return pass announcement is “Character N”
- [x] Do not say “Return to Character N” in TTS
- [x] Do not speak original prompt on return pass
- [x] Do not display original prompt on return pass

## 17.3 Tests

- [x] Unit test: prompt reading replaces begin
- [x] Unit test: segment over 30 seconds announces 30 seconds
- [x] Unit test: segment over 30 seconds announces 10 seconds
- [x] Unit test: segment over 30 seconds announces time
- [x] Unit test: exactly 30-second segment has no timer announcements
- [x] Unit test: exactly 30-second prompt segment reads only prompt
- [x] Unit test: exactly 30-second no-prompt segment stays silent
- [x] Unit test: regroup is silent
- [x] Unit test: A-to-C default behavior
- [x] Unit test: Character Creation first-pass announcement
- [x] Unit test: Character Creation return-pass announcement
- [x] Unit test: paused state suppresses announcements

---

# Milestone 18: Wire Hands-Free Mode Into Drills

## 18.1 Shared Hands-Free Wiring

- [x] Add Hands-Free Mode toggle to drill configuration where appropriate
- [x] Hands-Free Mode default is off
- [x] Use global TTS settings
- [x] Use fake TTS in tests
- [x] Stop button calls TTS stop
- [x] Pause suppresses announcements
- [x] Resume continues announcement behavior

## 18.2 Cat/Clock Hands-Free

- [x] Read both prompts together at start of speaking rep
- [x] Example: “cat, clock”
- [x] Stay silent during regroup
- [x] For 3-minute speaking segment, announce 30 seconds
- [x] For 3-minute speaking segment, announce 10 seconds
- [x] For 3-minute speaking segment, announce time

## 18.3 Two-Character Scenes Hands-Free

- [x] Read prompt when scene starts
- [x] Announce 30 seconds for 90-second scene
- [x] Announce 10 seconds for 90-second scene
- [x] Announce time for 90-second scene
- [x] Stay silent during regroup

## 18.4 A-to-C Hands-Free

- [x] Read each new prompt aloud
- [x] Default 30-second interval has no timer announcements
- [x] Longer intervals follow standard announcement policy
- [x] Pause freezes prompt changes and announcements

## 18.5 Five Line Game Hands-Free

- [x] Read prompt when shown
- [x] If auto-advance is off, no timer announcements
- [x] If auto-advance is on, read each new prompt
- [x] If interval is 30 seconds, no timer announcements
- [x] If interval is longer than 30 seconds, use standard timer announcements

## 18.6 Character Creation Hands-Free

- [x] Automatically generate prompts on first passes
- [x] Display generated prompt during first pass
- [x] Speak “Character N: prompt”
- [x] On return pass, speak only “Character N”
- [x] Do not display original prompt on return pass
- [x] Do not speak original prompt on return pass

## 18.7 Tests

- [x] Widget/unit test: Hands-Free default is off
- [x] Widget/unit test: Cat/Clock speaks prompt pair
- [x] Widget/unit test: Cat/Clock regroup is silent
- [x] Widget/unit test: Two-Character Scenes speaks prompt
- [x] Widget/unit test: A-to-C 30-second prompt has no timer announcement
- [x] Widget/unit test: Five Line Game speaks prompt
- [x] Widget/unit test: Character Creation auto-generates prompt in Hands-Free
- [x] Widget/unit test: Character Creation first pass speaks label and prompt
- [x] Widget/unit test: Character Creation return pass speaks only character label
- [x] Widget/unit test: pause suppresses announcements
- [x] Widget/unit test: stop calls TTS stop

---

# Milestone 19: Practice History

## 19.1 Session Logging

- [x] Add session logging service
- [x] Log drill session if duration is at least 30 seconds
- [x] Do not log sessions under 30 seconds
- [x] Log drill ID/name
- [x] Log date/time
- [x] Log duration
- [x] Do not log prompts used
- [x] Do not log settings used
- [x] Logging is silent
- [x] No “Session saved” toast/snackbar
- [x] No completion summary screen

## 19.2 Wire Logging Into Drills

- [x] Wire logging into Cat/Clock
- [x] Wire logging into Character Creation
- [x] Wire logging into Two-Character Scenes
- [x] Wire logging into A-to-C
- [x] Wire logging into Five Line Game
- [x] Do not log standalone Prompt Generator usage
- [x] Do not log standalone Timer usage
- [x] Do not log Emotion Wheel usage
- [x] Do not log Journal usage

## 19.3 Stats Calculations

- [x] Calculate total practice time
- [x] Calculate sessions completed
- [x] Calculate current streak
- [x] Calculate longest streak
- [x] Calculate breakdown by drill
- [x] Practice day requires at least one qualifying drill session
- [x] Journal entries do not count toward streak
- [x] Standalone tools do not count toward streak

## 19.4 History UI

- [x] History tab shows summary first
- [x] Add Practice Stats section/button
- [x] Add Journal section/button
- [x] Show total practice time
- [x] Show sessions completed
- [x] Show current streak
- [x] Show longest streak
- [x] Show breakdown by drill
- [x] Show recent sessions
- [x] Recent list shows most recent 20 sessions
- [x] No date filters in v1
- [x] No drill filters in v1
- [x] No individual session deletion in v1

## 19.5 Tests

- [x] Unit test: under 30 seconds does not log
- [x] Unit test: exactly 30 seconds logs
- [x] Unit test: over 30 seconds logs
- [x] Unit test: total practice time
- [x] Unit test: sessions completed
- [x] Unit test: current streak
- [x] Unit test: longest streak
- [x] Unit test: breakdown by drill
- [x] Unit test: standalone tools do not affect streaks
- [x] Unit test: journal entries do not affect streaks
- [x] Widget test: History shows Practice Stats section/button
- [x] Widget test: recent list shows most recent 20 sessions
- [x] Widget test: no individual delete control is present

---

# Milestone 20: Practice Journal

## 20.1 Journal Access

- [x] Journal is accessible from History tab
- [x] Journal is accessible from Tools section
- [x] History tab has separate Practice Stats and Journal subsections/buttons
- [x] Journal does not require a completed practice session
- [x] Journal is optional

## 20.2 Journal CRUD

- [x] Create journal entry
- [x] Edit journal entry
- [x] Delete journal entry
- [x] Store created date
- [x] Store updated date
- [x] Store optional drill tag
- [x] Store body text
- [x] Do not require link to specific session

## 20.3 Journal List

- [x] Show entries newest-first
- [x] Show date
- [x] Show optional drill tag
- [x] Show short preview
- [x] No search in v1
- [x] No filters in v1

## 20.4 Tests

- [x] Widget test: Journal reachable from History
- [x] Widget test: Journal reachable from Tools
- [x] Widget test: create entry
- [x] Widget test: edit entry
- [x] Widget test: delete entry
- [x] Unit/widget test: entries sort newest-first
- [x] Unit test: journal entries do not affect streaks

---

# Milestone 21: Standalone Timer Tool

## 21.1 Timer Tool Access

- [x] Timer tool is reachable from Tools
- [x] Timer tool does not appear as bottom nav item
- [x] Timer tool is clearly separate from drill timers
- [x] Timer tool usage does not count toward history/streaks

## 21.2 Simple Countdown Mode

- [x] User can configure countdown duration
- [x] User can start countdown
- [x] User can pause countdown
- [x] User can resume countdown
- [x] User can stop/reset countdown
- [x] Show large timer
- [x] Show progress indicator if appropriate

## 21.3 Interval Cycle Mode

- [x] User can configure work time
- [x] User can configure regroup/rest time
- [x] Timer alternates work/rest
- [x] Timer repeats cycle until stopped
- [x] Pause/resume works
- [x] Stop/reset works
- [x] Keep UI simple

## 21.4 Tests

- [x] Widget test: Timer tool reachable
- [x] Unit/widget test: simple countdown completes
- [x] Unit/widget test: interval alternates work/rest
- [x] Widget test: pause/resume
- [x] Widget test: stop/reset
- [x] Unit test: Timer tool does not create practice history records

---

# Milestone 22: Interactive Emotion Wheel

## 22.1 Emotion Wheel Access

- [x] Emotion Wheel reachable from Tools
- [x] Emotion Wheel does not appear in bottom nav
- [x] Emotion Wheel is self-contained

## 22.2 Emotion Wheel Interaction

- [x] Show broad emotion categories
- [x] Allow tapping broad emotion category
- [x] Reveal more specific emotions
- [x] Allow selecting specific emotion
- [x] Display selected emotion as prompt within tool
- [x] Do not send selected emotion into drills in v1
- [x] Keep UI interactive, not static image
- [x] Keep UI accessible

## 22.3 Content Safety

- [x] Use original placeholder taxonomy for now
- [x] Do not copy protected emotion wheel images
- [x] Do not copy protected article text
- [ ] Document final taxonomy as separate content/design task

## 22.4 Tests

- [x] Widget test: Emotion Wheel reachable from Tools
- [x] Widget test: broad categories appear
- [x] Widget test: tapping category reveals specific emotions
- [x] Widget test: selecting emotion displays selected emotion
- [x] Widget test: no “send to drill” action exists
- [x] Accessibility/widget test: emotion controls have labels

---

# Milestone 23: Settings

## 23.1 Settings Sections

- [x] Add Appearance section
- [x] Add Text-to-Speech section
- [x] Add Data Backup section
- [x] Add Privacy/About section
- [x] Add Support/Donate section

## 23.2 Appearance Settings

- [x] Add System theme option
- [x] Add Light theme option
- [x] Add Dark theme option
- [x] Default is System
- [x] Theme preference persists locally
- [x] App applies selected theme
- [x] Theme changes do not require restart if practical

## 23.3 Reset Drill Defaults

- [x] Add Reset Drill Defaults action
- [x] Show standard confirmation dialog
- [x] Restore all drill timings to defaults
- [x] Restore all prompt category selections to defaults
- [x] Restore all drill-specific options to defaults
- [x] Do not delete custom prompts
- [x] Do not delete journal entries
- [x] Do not delete practice history
- [x] Do not reset app theme
- [x] Do not reset TTS settings unless specifically part of drill defaults

## 23.4 Reset All Data

- [x] Add Reset All Data action
- [x] Show standard confirmation dialog
- [x] Delete custom prompts
- [x] Delete journal entries
- [x] Delete practice history
- [x] Reset saved drill settings
- [x] Reset theme preference
- [x] Reset TTS settings
- [x] Reset other local preferences
- [x] No need to type RESET
- [x] Built-in prompts remain available after reset

## 23.5 Tests

- [x] Widget test: Settings sections appear
- [x] Widget test: theme preference can be changed
- [x] Repository/widget test: theme preference persists
- [x] Unit/widget test: Reset Drill Defaults restores drill defaults
- [x] Unit/widget test: Reset Drill Defaults preserves custom prompts
- [x] Unit/widget test: Reset Drill Defaults preserves journal entries
- [x] Unit/widget test: Reset Drill Defaults preserves practice history
- [x] Unit/widget test: Reset All Data clears expected local data
- [x] Unit/widget test: Reset All Data preserves built-in prompts
- [x] Widget test: reset actions show confirmation dialogs

---

# Milestone 24: JSON Export / Import Backup

## 24.1 Data Backup UI

- [x] Add Export Data button
- [x] Add Import Data button
- [x] Data Backup appears only in Settings
- [x] Export/import does not appear on History screen
- [x] Export/import does not appear on Journal screen
- [x] Show local-only backup warning near Export/Import
- [x] Warning says data stays on this device unless exported
- [x] Warning says uninstalling or switching devices may delete local data

## 24.2 JSON Export

- [x] Generate one JSON backup file
- [x] Use native share/save flow where available
- [x] Include schema version
- [x] Include app/export version metadata
- [x] Include custom prompts
- [x] Include journal entries
- [x] Include practice history
- [x] Include saved drill settings
- [x] Include theme preference
- [x] Include TTS settings
- [x] Include other safe app preferences
- [x] Exclude current app state
- [x] Exclude pending crash-report state
- [x] Exclude transient runtime data
- [x] Exclude blocked prompt attempts
- [x] Exclude any audio/microphone data because none should exist

## 24.3 JSON Import

- [x] Accept Hermit Prov JSON backup file
- [x] Validate schema version
- [x] Reject unsupported future schema version
- [x] Show clear future-version error
- [x] Migrate older supported schema versions
- [x] Import current schema version normally
- [x] Merge imported data with existing local data
- [x] Skip duplicate custom prompts
- [x] Skip duplicate journal entries
- [x] Skip duplicate practice sessions
- [x] Skip duplicate/equivalent settings where appropriate
- [x] Do not show review screen in v1
- [x] Do not overwrite everything by default

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

- [x] Unit test: export includes expected data
- [x] Unit test: export excludes current app state
- [x] Unit test: export excludes transient data
- [x] Unit test: export excludes blocked prompt attempts
- [x] Unit test: import merges data
- [x] Unit test: import skips duplicate custom prompts
- [x] Unit test: import skips duplicate journal entries
- [x] Unit test: import skips duplicate practice sessions
- [x] Unit test: unsupported future schema version is rejected
- [x] Unit test: future-version error message is clear
- [x] Unit test: older supported schema migrates
- [x] Widget test: Export and Import controls visible only in Settings
- [x] Widget test: backup warning appears

---

# Milestone 25: Privacy, About, Credits, Support, Donate

## 25.1 Privacy/About Page

- [x] Add Privacy/About page
- [x] Page reachable from Settings
- [x] State no account
- [x] State no login
- [x] State no cloud sync
- [x] State fully usable offline after installation
- [x] State user data stays on-device
- [x] State no audio recording
- [x] State no microphone permission
- [x] State no speech recognition
- [x] State prompts are not sent anywhere by default
- [x] State journal entries are not sent anywhere by default
- [x] State practice history is not sent anywhere by default
- [x] State optional crash reports are user-triggered only after a crash
- [x] State crash reports include technical details and app state
- [x] State crash reports exclude custom prompts and journal entries
- [x] State data is local-only
- [x] Warn users to export before deleting app or switching devices
- [x] Include visible No Recording assurance

## 25.2 Credits and Attribution

- [x] Add Credits section
- [x] Link to Will Hines solo improv practice article
- [x] Link to referenced prompt-generator inspiration sites
- [x] Link to referenced emotion-wheel inspiration article
- [x] Clearly state Hermit Prov is unofficial
- [x] Clearly state Hermit Prov is unaffiliated with Will Hines
- [x] Clearly state Hermit Prov is unaffiliated with prompt-generator sites
- [x] Clearly state Hermit Prov is unaffiliated with emotion-wheel inspiration sources
- [x] Keep attribution out of individual drill screens

## 25.3 Content Licensing Notes

- [x] Document that built-in exercise descriptions must be original wording
- [x] Document that prompt lists must be original/properly licensed/public-domain/safe-to-use
- [x] Document that emotion-wheel labels/taxonomy must be original/properly licensed/safe-to-use
- [x] Do not copy article text verbatim except exercise names
- [x] Do not copy protected prompt lists
- [x] Do not copy protected emotion wheel images/assets

## 25.4 Support Email

- [x] Add Support / Feedback link
- [x] Support link opens email to developer
- [x] Email template includes app version
- [x] Email template includes device OS
- [x] Email template includes short issue prompt
- [x] User can edit everything before sending
- [x] Email does not automatically include custom prompts
- [x] Email does not automatically include journal entries
- [x] Email does not automatically include practice history

## 25.5 Donate Link

- [x] Add low-key Ko-fi link
- [x] Link opens external Ko-fi page
- [x] Donate link appears only in Settings/About area
- [x] No donation prompt after practice sessions
- [x] No in-app purchase
- [x] No subscription
- [x] No pressure messaging

## 25.6 Tests

- [x] Widget test: Privacy/About reachable
- [x] Widget test: No Recording assurance appears
- [x] Widget test: local-only warning appears
- [x] Widget test: unaffiliated disclaimer appears
- [x] Widget test: support link exists
- [x] Unit/widget test: support email excludes user-created local data
- [x] Widget test: Ko-fi link exists only in Settings/About area
- [x] Widget test: no donation prompt after completing a drill session

---

# Milestone 26: Optional Crash Report Prompt

## 26.1 Crash Report Architecture

- [x] Add CrashReportProvider interface
- [x] Add fake/no-op crash-report provider
- [x] Add crash payload model
- [x] Add crash payload sanitizer
- [x] Do not send crash reports automatically
- [x] Do not persist crash-report opt-in preference
- [x] Crash prompt appears only after crash condition
- [x] Real provider integration can be configured later if desired

## 26.2 Crash Prompt

- [x] Prompt offers Send Report
- [x] Prompt offers Don’t Send
- [x] Prompt includes privacy note
- [x] Privacy note says report includes technical details and app state
- [x] Privacy note says report excludes custom prompts and journal entries
- [x] Link Privacy/About from crash prompt if practical

## 26.3 Crash Payload Rules

- [x] Payload may include technical crash details
- [x] Payload may include device OS/version
- [x] Payload may include app version
- [x] Payload may include screen name
- [x] Payload may include active drill
- [x] Payload may include timer value
- [x] Payload may include safe settings/app state
- [x] Payload must exclude custom prompts
- [x] Payload must exclude journal entries
- [x] Payload must exclude audio data
- [x] Payload must exclude microphone data
- [x] Payload must exclude user-created content

## 26.4 Tests

- [x] Unit test: sanitizer excludes custom prompts
- [x] Unit test: sanitizer excludes journal entries
- [x] Unit test: sanitizer excludes user-created content
- [x] Unit test: sanitizer includes allowed app state
- [x] Widget test: crash prompt shows Send Report
- [x] Widget test: crash prompt shows Don’t Send
- [x] Widget test: crash prompt shows privacy note
- [x] Widget test: Don’t Send does not call provider
- [x] Widget test: Send Report calls provider with sanitized payload
- [x] Unit test: no persistent crash-report preference exists

---

# Milestone 27: Accessibility, Tablet Layout, Orientation, Permissions

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

# Milestone 28: Final Integration and Acceptance Testing

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

- [x] Research prompt-list sources and licensing
- [x] Create robust Objects list
- [x] Create robust Locations list
- [x] Create robust Relationships list
- [x] Create robust Occupations list
- [x] Create robust Emotions list
- [x] Create robust Activities list
- [x] Ensure no specific brands
- [x] Ensure no celebrities
- [x] Ensure no copyrighted fictional character names
- [x] Ensure no slurs
- [x] Ensure no explicitly sexual content
- [x] Ensure no hateful content
- [x] Allow mildly edgy adult-life prompts
- [x] Review prompt list for duplicates
- [x] Review prompt list for spelling/format consistency
- [x] Convert prompt lists into app seed format
- [x] Add content version metadata if useful

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

Hermit Prov v1 is done when:

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
