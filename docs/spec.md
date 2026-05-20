# Hermit Prov — Developer Handoff Specification

## 1. Product Summary

**Hermit Prov** is a free, offline-first, cross-platform mobile app for solo long-form comedy improv practice. It provides guided practice drills inspired by solo improv exercises, plus standalone tools such as a prompt generator, timer, emotion wheel, and practice journal.

The app is designed for:

- Beginner improvisers who want simple guided practice.
- Intermediate and advanced improvisers who want fast reps without handholding.
- The creator as the first power user.

Hermit Prov should feel like a private, lightweight practice room: open the app, choose a drill, practice out loud, and leave. It should not feel like a social app, gamified habit app, AI coach, or content platform.

## 2. Product Philosophy

Hermit Prov is:

- A private, self-directed practice tool.
- Fully usable offline after installation.
- Local-first and local-only for user data.
- Built around timed repetition, prompts, and improv muscle-building.
- Playful, but not obnoxiously so.
- Simple enough for beginners, configurable enough for experienced improvisers.

Hermit Prov is not:

- An AI coach.
- A performance evaluator.
- A recording app.
- A speech-recognition app.
- A social practice platform.
- A gamified habit-pressure app.

### Permanent AI Constraint

Hermit Prov must **never** include AI-generated prompts or AI coaching in any version.

Prompts must come only from:

1. Human-curated static local prompt lists bundled with the app.
2. User-created custom prompts stored locally on the user’s device.

## 3. Core v1 Goals

Version 1 should include:

- Five guided solo improv drills:
  - Cat/Clock
  - Character Creation
  - Two-Character Scenes
  - A-to-C / Bad Idea / Initiation
  - Five Line Game Drill
- A locally stored curated prompt library.
- User-created custom prompts by category.
- Configurable drill settings saved locally per drill.
- Timer-based practice flows.
- Optional Hands-Free Mode with text-to-speech.
- Practice History with quiet personal stats.
- Practice Journal.
- Tools section with:
  - Prompt Generator
  - Timer
  - Emotion Wheel
  - Practice Journal
- JSON export/import backup.
- Optional user-triggered crash report submission after a crash.
- iOS and Android support.
- Tablet-friendly layouts.
- Accessibility support.

## 4. v1 Non-Goals / Explicit Exclusions

The following must not be included in v1:

- No accounts.
- No login.
- No cloud sync.
- No server-stored user data.
- No audio recording.
- No microphone permission.
- No speech recognition.
- No AI-generated prompts.
- No AI coaching.
- No AI feedback.
- No multiplayer practice.
- No social sharing.
- No public profiles.
- No leaderboards.
- No badges.
- No reward systems.
- No nagging reminders.
- No push notifications.
- No local reminder notifications.
- No ads.
- No subscriptions.
- No in-app purchases.

The only monetization/support element is a low-key external Ko-fi donation link in Settings/About.

## 5. Platform and Technical Direction

### Platforms

- iOS
- Android
- Phones and tablets

### Orientation

- Phones: portrait only.
- Tablets: portrait-first, tablet-friendly responsive layouts.

### Preferred Technology

- Flutter preferred.
- Another cross-platform framework is acceptable if it preserves:
  - Offline-first behavior.
  - Native iOS and Android support.
  - Local-only user data storage.
  - Reliable timer and text-to-speech behavior.
  - Tablet-friendly layouts.

### Local Storage

Developer may choose the local storage approach, but SQLite/Drift should be listed as an acceptable/preferred option.

The implementation must include an explicit local data schema for:

- Custom prompts.
- Journal entries.
- Practice history.
- Saved drill settings.
- App preferences.
- Import/export schema metadata.

## 6. App Navigation

The app should use bottom navigation with these main sections:

1. **Practice**
2. **History**
3. **Settings**

The **Tools** section should be reachable from the Practice home screen as a card, not duplicated in bottom navigation.

### Minimum Screen List

#### Practice

- Practice Home / Choose Your Drill
- Drill Start screen
- Drill Configure screen
- Drill Session screen
- Tools index screen
- Standalone Prompt Generator
- Standalone Timer
- Emotion Wheel
- Practice Journal shortcut

#### History

- History landing screen
- Practice Stats section
- Journal section

#### Settings

- Settings main screen
- Appearance settings
- Text-to-Speech settings
- Data Backup settings
- Privacy/About page
- Support/Feedback
- Donate link

## 7. First Launch / Onboarding

No onboarding flow for v1.

On first launch and future launches, the app opens directly to the **Practice** tab / **Choose Your Drill** screen.

Drill-specific instructions should be available through info/help buttons instead of interrupting the user with onboarding screens.

## 8. Visual Design Direction

Hermit Prov should be:

- Playful, but not obnoxious.
- Clean and easy to use.
- Light enough to feel like a practice utility.
- Not overly childish or cluttered.

A small mascot is acceptable, such as a subtle hermit-crab-improviser concept, but the design should rely more on typography, color, spacing, and small playful UI details than on heavy character branding.

Exact colors, typography, and illustration direction are intentionally left for a later design step.

## 9. Practice Home / Choose Your Drill

The Practice home screen should show cards for:

1. Cat/Clock
2. Character Creation
3. Two-Character Scenes
4. A-to-C / Bad Idea / Initiation
5. Five Line Game Drill
6. Tools

Each card should include:

- Drill/tool name.
- Short subtitle.

Cards should stay clean. They should not show saved settings such as timer length or categories.

Example subtitle direction:

- Cat/Clock — “Connect two prompts through association.”
- Character Creation — “Cycle through solo character reps.”
- Two-Character Scenes — “Prompt + timed two-character scene.”
- A-to-C / Bad Idea / Initiation — “Rapid-fire prompt reps.”
- Five Line Game Drill — “One prompt, fast five-line scenes.”
- Tools — “Prompt generator, timer, emotion wheel, journal.”

## 10. Drill Start and Configure Pattern

Each drill should have a Drill Start screen with:

- Drill name.
- Short subtitle or brief description.
- Primary **Start** button.
- Secondary **Configure** button.
- Info/help button.

The **Start** button launches the drill using the saved configuration for that drill. If the user has never configured the drill, Start uses the default configuration.

The **Configure** button opens drill-specific settings.

When a user changes a drill configuration and taps Start, those changes are saved immediately as the new local default for that drill.

Settings are saved locally per drill.

## 11. Drill Info / Help Screens

Each drill should have an info/help button.

Info/help content should:

- Be neutral and practical.
- Explain how to use the drill screen.
- Paraphrase the source exercise ideas in original wording.
- Avoid copying article text verbatim except for exercise names.
- Avoid placing attribution on every drill screen.

Attribution belongs in About/Credits only.

## 12. Shared Drill Session Controls

Each active drill session should include:

- Large countdown timer where applicable.
- Circular progress indicator.
- Current prompt or current drill label where applicable.
- Pause/Resume control.
- Stop/End control.

### Pause / Resume

When paused:

- Timer freezes exactly where it is.
- Prompt changes freeze.
- No new prompts appear.
- No text-to-speech announcements occur.

When resumed:

- The drill continues from the paused state.

### Stop / End

When the user taps Stop/End:

- Show a confirmation dialog to prevent accidental stopping.
- If confirmed, end the session and return to the drill’s Start screen.
- Do not show a completion summary screen.

### Practice History Logging

A drill session is logged to Practice History if the user spends at least 30 seconds in a drill.

After logging:

- Logging should be silent.
- Do not show “Session saved.”
- Return directly to the drill Start screen.

## 13. Timer Display and Progress Indicator

The timer should be shown as large numeric text.

A circular progress ring should accompany the timer.

For finite drills or finite cycles:

- The progress ring shows progress through the current rep/cycle.

For looping drills that continue until the user stops:

- The progress ring shows progress through the current rep, not the entire session.

The app should generally rely on the countdown and progress ring rather than additional state labels like “Speaking,” “Regroup,” “Paused,” or “Time.”

Exception: Character Creation must show the current character label, such as “Character 1” or “Return to Character 2.”

## 14. Prompt System

### Built-In Prompt Library

Version 1 should ship with robust human-curated local prompt lists.

Prompt-list creation is a separate content/research deliverable, not part of the developer’s core implementation unless separately assigned.

The spec should include placeholder content requirement:

> Ship with robust human-curated local prompt lists for Objects, Locations, Relationships, Occupations, Emotions, and Activities.

### Prompt Categories

The core v1 prompt categories are:

- Objects
- Locations
- Relationships
- Occupations
- Emotions
- Activities

### “Word” Bucket

The app should support a main **word** generation bucket.

The word bucket means: all prompts available to the generator across all prompt categories.

### Built-In Prompt Content Rules

Built-in prompt lists must follow these rules:

- No specific brands.
- No celebrities.
- No copyrighted fictional character names.
- No slurs.
- No explicitly sexual content.
- No hateful content.
- Mildly edgy adult-life prompts are allowed.

Allowed examples:

- Divorce
- Jealousy
- Hangover
- Firing someone
- Bad date
- Debt
- Funeral

Generic equivalents should be used instead of brands/celebrities/fictional characters.

Examples:

- “Masked vigilante” instead of “Batman.”
- “Pop star” instead of a specific celebrity.
- “Coffee chain” instead of a specific coffee brand.
- “Theme park” instead of a specific branded park.

### Custom Prompts

Users can add custom prompts.

Custom prompts must be added to existing prompt categories:

- Objects
- Locations
- Relationships
- Occupations
- Emotions
- Activities

Custom prompts are mixed automatically with built-in prompts during drills.

Users do not choose “built-in only,” “custom only,” or “both” in v1.

Users can:

- Add custom prompts.
- Edit custom prompts.
- Delete custom prompts.

Users cannot manage built-in prompts in v1.

No disabling, editing, or deleting individual built-in prompts in v1.

### Custom Prompt Validation

Custom prompt validation must happen entirely on-device.

No network calls for prompt validation.

Validation should:

- Broadly block slurs.
- Narrowly block clearly explicit/graphic sexual content.
- Allow non-graphic adult relationship/dating prompts.

Allowed examples:

- Bad date
- Affair
- Crush
- Flirting
- Awkward hookup
- Divorce

Blocked sexual content should be limited to clearly explicit/graphic material.

When a prompt is blocked:

- Show a simple error message.
- Do not explain the specific reason.
- Do not log the blocked attempt.
- Do not save any record of the rejected prompt.

Example error:

> This prompt can’t be saved because it violates content rules.

## 15. Prompt Category Configuration by Drill

Each drill should have intelligent default prompt categories.

Users should be able to change which categories a drill uses.

Category choices are saved locally per drill.

Default for most prompt-based drills should be the full **word** bucket unless otherwise specified.

## 16. Hands-Free Mode and Text-to-Speech

### General

Hands-Free Mode is optional and off by default.

Hands-Free Mode is toggled inside individual drill sessions or drill configuration, not as an app-wide default.

Text-to-speech settings are global.

Users can configure:

- TTS voice.
- TTS speaking rate.

TTS settings apply across the whole app.

### Hands-Free Announcements

For non-character drills:

- The app reads the prompt aloud when it appears.
- Reading the prompt replaces the “begin” announcement.

Timer announcements apply only to segments longer than 30 seconds.

For segments longer than 30 seconds:

- Announce “30 seconds.”
- Announce “10 seconds.”
- Announce “time.”

For exactly 30-second segments:

- No timer announcements.
- If there is a prompt, read the prompt.
- If there is no prompt, stay silent.

For regroup segments:

- Stay silent.

### Hands-Free and Pause

When paused:

- No TTS announcements.

When resumed:

- Continue normal announcement behavior from that point forward.

## 17. Drill 1 — Cat/Clock

### Purpose

A prompt-pair association drill where the user practices connecting two unrelated prompts aloud.

### Default Flow

- Generate two prompts at the start of a rep.
- Run a speaking timer.
- End the rep visibly.
- Run a regroup timer.
- Automatically generate the next prompt pair.
- Repeat until the user manually stops.

### Default Timing

- Speaking: 3 minutes.
- Regroup: 30 seconds.

Both durations are configurable and saved locally.

### Prompt Defaults

- Default prompt setup: two words from the full word bucket.
- The user can configure which categories each of the two prompts uses.
- Example configurable pairings:
  - Word + Word
  - Object + Location
  - Emotion + Activity
  - Any category combination allowed by the prompt system.

### Looping

Cat/Clock continues automatically until the user manually stops.

### Hands-Free Behavior

At the beginning of each speaking rep:

- Read both prompts aloud together, e.g. “cat, clock.”

During the 30-second regroup:

- Stay silent.

For the 3-minute speaking segment:

- Since segment is longer than 30 seconds, use timer announcements:
  - “30 seconds”
  - “10 seconds”
  - “time”

## 18. Drill 2 — Character Creation

### Purpose

A solo character cycling drill where the user creates and returns to characters in timed segments.

### Default Setup

- Default number of characters: 2.
- Configurable number of characters: up to approximately 5.
- Default time per character segment: 60 seconds.
- Time-per-character options:
  - 60 seconds
  - 90 seconds
  - 120 seconds

No arbitrary custom duration for v1.

### Cycle Structure

Each character gets two passes:

1. First pass: establish/create the character.
2. Return pass: return to that character later.

Total cycle duration scales based on number of characters:

> Number of characters × 2 passes × selected segment duration

Example with 2 characters and 60-second segments:

1. Character 1 — 60 seconds
2. Character 2 — 60 seconds
3. Return to Character 1 — 60 seconds
4. Return to Character 2 — 60 seconds

Example with 5 characters and 60-second segments:

1. Character 1
2. Character 2
3. Character 3
4. Character 4
5. Character 5
6. Return to Character 1
7. Return to Character 2
8. Return to Character 3
9. Return to Character 4
10. Return to Character 5

The session ends when the full cycle is complete.

It does not loop indefinitely by default.

### On-Screen Labels

During first pass:

- Show “Character 1,” “Character 2,” etc.

During return pass:

- Show “Return to Character 1,” “Return to Character 2,” etc.

### Prompt Generation

Prompt generation is optional and manual in normal mode.

Normal mode:

- During each character’s first pass, show a **Generate Prompt** button.
- If the user taps it, generate and display a prompt for that character.
- The Generate Prompt button appears only during first passes.
- The Generate Prompt button does not appear on return passes.
- Remembering the character is part of the drill, so there should be no Character List or review button.
- On return pass, do not display the original prompt.

Hands-Free Mode:

- Prompt generation must be automatic on each character’s first pass, because hands-free practice should not require tapping.
- The app should display the generated prompt visually during the first pass.
- The app should read aloud both the character label and generated prompt, e.g. “Character 1: dentist.”
- On return pass, announce only “Character 1” or “Character 2,” not “Return to Character 1.”
- On return pass, do not display the original prompt.

### Prompt Source

Default prompt source:

- Word bucket.

Prompt categories are configurable and saved per drill.

## 19. Drill 3 — Two-Character Scenes

### Purpose

A timed two-character scene drill using a single prompt.

### Default Flow

- Show one prompt.
- Run timer.
- End the rep.
- Run a short regroup.
- Automatically generate a new prompt.
- Repeat until stopped.

### Default Timing

- Scene timer: 90 seconds.
- Regroup timer: 30 seconds.

Both are configurable and saved locally.

### Prompt Source

Default prompt source:

- Word bucket.

Prompt categories are configurable and saved per drill.

### Screen Behavior

The app should not display which character is speaking.

It is just:

- Prompt.
- Timer.
- Pause/Resume.
- Stop/End.

### Hands-Free Behavior

- Read each prompt aloud when it appears.
- For the 90-second segment, use timer announcements:
  - “30 seconds”
  - “10 seconds”
  - “time”
- Stay silent during the 30-second regroup.

## 20. Drill 4 — A-to-C / Bad Idea / Initiation

### Purpose

A rapid-fire prompt drill where the prompt changes on a short interval.

This is one combined drill with a complex name, not three separate drills.

### Default Flow

- Show a prompt.
- Timer counts down.
- Prompt changes automatically at the interval.
- Repeat rapid-fire until stopped.

### Default Timing

- Prompt change interval: 30 seconds.

Configurable preset options:

- 15 seconds
- 30 seconds
- 45 seconds
- 60 seconds

Saved locally per drill.

### Prompt Source

Default prompt source:

- Word bucket.

Prompt categories are configurable and saved per drill.

### Hands-Free Behavior

- Read each new prompt aloud when it appears.
- Since the default interval is 30 seconds, no timer announcements at 30 seconds.
- For intervals longer than 30 seconds, use standard timer announcements.
- For exactly 30-second intervals, only read the prompt.

## 21. Drill 5 — Five Line Game Drill

### Purpose

A fast scene-repetition drill where the user gets a prompt and performs a five-line scene on their own.

### Default Flow

- Show one prompt.
- User performs the five-line scene independently.
- User can tap **New Prompt** for another rep.

The app should not try to know which line is being spoken.

Do not display:

- Line 1 / Line 2 / Line 3 / Line 4 / Line 5
- Initiation / response / heightening / turn / button

### Timer

No timer required by default.

Optional auto-advance interval may be enabled.

Auto-advance default:

- Off.

Selectable intervals when enabled:

- 30 seconds
- 60 seconds
- 90 seconds

### Prompt Source

Default prompt source:

- Word bucket.

Prompt categories are configurable and saved per drill.

### Hands-Free Behavior

If auto-advance is off:

- Read prompt when shown.
- No timer announcements.

If auto-advance is on:

- Read each new prompt aloud.
- Standard announcement rules apply only if the interval is longer than 30 seconds.

## 22. Tools Section

The Tools section is accessed from the Practice home screen as a card.

Tools included in v1:

1. Prompt Generator
2. Timer
3. Emotion Wheel
4. Practice Journal

## 23. Tool — Standalone Prompt Generator

The standalone Prompt Generator should let users:

- Select any combination of prompt categories.
- Select the full word bucket.
- Tap **New Prompt** manually.
- Enable optional auto-advance.

Auto-advance intervals:

- 15 seconds
- 30 seconds
- 45 seconds
- 60 seconds

This tool uses the same built-in + custom prompt system as drills.

## 24. Tool — Standalone Timer

The standalone Timer should support:

- Simple configurable countdown timer.
- Interval cycles such as work time + regroup/rest time.

The timer tool is separate from drill timers but may reuse shared timer components.

## 25. Tool — Emotion Wheel

The Emotion Wheel should be interactive, not a static image.

It should be inspired by common emotion wheel designs where broad emotions can be drilled into more specific emotions.

Requirements:

- User can browse broad emotion categories.
- User can drill down into more specific emotions.
- User can select an emotion as a prompt within the Emotion Wheel tool.

For v1, selected emotions stay inside the Emotion Wheel tool.

Do not send selected emotions directly into drills in v1.

For drills, emotions are available through the Emotions prompt list.

Emotion-wheel labels and structure must be original, properly licensed, or otherwise safe to use. Do not copy image assets or protected content from referenced sites.

## 26. Tool — Practice Journal

The Practice Journal is accessible from:

- Tools section.
- History tab.

Journal use is optional.

Users should never be required to create a journal entry after a session.

## 27. Practice History

Practice History should track local practice activity only.

### What Counts as Practice

A practice day counts when the user completes at least one drill session of at least 30 seconds.

Using standalone tools does not count toward streaks.

Adding a journal entry does not count toward streaks.

### Session Logging

A drill session is logged if the user spends at least 30 seconds in a drill.

Stored session fields:

- Drill name.
- Date/time.
- Duration.

Do not store:

- Prompts used.
- Settings used.

Settings are saved separately as the drill’s local default configuration.

### History Dashboard

The History tab should show a summary first.

Summary should include:

- Total practice time.
- Sessions completed.
- Current streak.
- Longest streak.
- Breakdown by drill.

Streaks should be quiet personal stats only.

No badges, rewards, celebratory popups, leaderboards, public streaks, or pressure messaging.

### Recent Sessions

Show the most recent 20 sessions by default.

Keep v1 simple:

- No filtering by drill.
- No filtering by date range.
- No individual session deletion.

History can be cleared only through Reset All Data.

## 28. Practice Journal Details

Journal entries should be tagged by:

- Date.
- Optional drill name.

Journal entries should support:

- Create.
- Edit.
- Delete.

Journal list should show entries newest-first.

Each list item should show:

- Date.
- Optional drill tag.
- Short text preview.

Keep v1 simple:

- No search.
- No filters.
- No required linking to specific practice sessions.

## 29. History Tab Structure

The History tab should not cram everything onto one screen.

It should provide separate sub-sections/buttons for:

1. Practice Stats
2. Journal

## 30. Settings Screen

Settings should group options into sections:

1. Appearance
2. Text-to-Speech
3. Drill Defaults
4. Data Backup
5. Privacy/About
6. Support/Donate

## 31. Settings — Appearance

Theme options:

- System
- Light
- Dark

Default:

- System

## 32. Settings — Text-to-Speech

Users can configure global TTS settings:

- Voice.
- Speaking rate.

These apply globally across drills and tools that use TTS.

Hands-Free Mode itself is not an app-wide default setting. It is toggled inside individual drills/configuration.

## 33. Settings — Drill Defaults

Saved drill configurations are primarily edited from each drill’s Configure button.

Settings should also include:

- **Reset Drill Defaults** action.

Reset Drill Defaults should:

- Restore all drill timings, prompt categories, and drill-specific options to built-in defaults.
- Not delete journal entries.
- Not delete custom prompts.
- Not delete practice history.
- Require a standard confirmation dialog.

## 34. Settings — Data Backup

Data Backup section should include:

- Export Data
- Import Data
- Local-only backup warning

Export/import should live only in Settings, not on History or Journal screens.

### Backup Warning

Show a warning near Export/Import:

> Data stays on this device unless you export it. Uninstalling the app or switching devices may delete your local data.

Also include similar language on the Privacy/About page.

## 35. JSON Export / Import

Hermit Prov should support both export and import of user data.

### Export

Export should generate one local JSON backup file on demand and use the phone’s native share sheet/save flow.

JSON is preferred over CSV because it can preserve nested settings and multiple data types.

### Import

Import should accept a Hermit Prov JSON backup file.

Import behavior:

- Merge imported data with existing local data.
- Skip duplicates automatically.
- Do not show a review screen in v1.

### Duplicate Handling

During import, skip duplicates for:

- Custom prompts.
- Journal entries.
- Practice history records.
- Settings where identical values already exist.

Developer should define robust duplicate rules in the local data schema.

### Exported Data Should Include

- Schema version.
- App/export version metadata.
- Custom prompts.
- Journal entries.
- Practice history.
- Saved drill settings.
- Theme preference.
- Text-to-speech settings.
- Other app preferences that are relevant and safe to back up.

### Exported Data Should Exclude

- Current app state.
- Pending crash report state.
- Any transient runtime data.
- Any blocked prompt attempts.

Because crash reports are never automatic, there should be no persistent crash-report opt-in setting to export.

### Schema Versioning

The JSON export file must include a human-readable schema version.

The developer must document the JSON schema.

Import behavior:

- Unsupported future schema version: reject with a clear message.
- Older supported schema version: migrate into current local schema.
- Current schema version: import normally.

Example future-version error:

> This backup was created by a newer version of Hermit Prov and can’t be imported by this app version.

The developer must document versioning and migration behavior so future versions can maintain compatibility.

## 36. Settings — Reset All Data

Settings should include **Reset All Data**.

Reset All Data deletes:

- Custom prompts.
- Journal entries.
- Practice history.
- Saved drill settings.
- Theme preference.
- Text-to-speech settings.
- Other local preferences.

Reset All Data should require a standard confirmation dialog.

No need to require typing RESET.

## 37. Privacy / About Page

The app should include an in-app Privacy/About page.

It should explain:

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
- Data is local-only, so users should export backups before deleting the app or switching devices.

### No Recording Assurance

Privacy/About should include a visible assurance:

> Hermit Prov does not record audio and does not request microphone permission.

This assurance only needs to appear in Privacy/About, not on drill screens.

### Credits and Attribution

About/Credits should include links to:

- Will Hines solo improv practice article.
- Referenced prompt-generator inspiration sites.
- Referenced emotion-wheel inspiration article.

The page must clearly state that Hermit Prov is unofficial and unaffiliated with:

- Will Hines.
- Prompt-generator sites.
- Emotion-wheel article/sites.
- Any referenced inspiration sources.

Attribution should not appear inside individual drill screens.

### Content Licensing Requirement

All built-in exercise descriptions, prompt lists, and emotion-wheel labels must be original, properly licensed, or public-domain/safe-to-use.

Do not copy protected text, prompt lists, images, or emotion-wheel assets from referenced sites.

## 38. Optional Crash Reporting

Hermit Prov is local-only except for optional user-triggered crash reporting.

Crash reports must not be automatic.

After a crash, the user may be prompted with:

- Send Report
- Don’t Send

Crash report prompt should include a brief privacy note:

> Includes technical crash details and app state, but not your custom prompts or journal entries.

Crash reports may include:

- Technical crash details.
- Device OS/version.
- App version.
- Recent app state such as active drill, timer value, settings, and screen name.

Crash reports must explicitly exclude:

- Custom prompts.
- Journal entries.
- Practice history content beyond non-sensitive aggregate context if needed.
- Any audio data.
- Any microphone data.

No crash report preference should be persisted because reporting is always prompted case-by-case.

Privacy/About should link from the crash-report prompt.

## 39. Support / Feedback

The app should include a Support / Feedback link.

It should be accessible from Settings.

It should open an email to the developer.

The email template should be prefilled with:

- App version.
- Device OS.
- A short prompt for the user’s issue.

The user must be able to edit everything before sending.

The support email template should explicitly exclude local user data unless the user manually chooses to type it.

Do not automatically include:

- Custom prompts.
- Journal entries.
- Practice history.

## 40. Donate

Settings/About should include a low-key external Ko-fi donation link.

Requirements:

- External page only.
- No in-app purchases.
- No subscriptions.
- No ads.
- No prominent donation prompts after practice sessions.
- No pressure messaging.

## 41. Permissions

The app should request only device permissions needed by actual features.

Explicit permission constraints:

- No microphone permission.
- No recording permission.
- No speech recognition permission.
- No push notification permission.
- No local notification permission.

Network access should only be needed when the user chooses to:

- Send a crash report.
- Open support email.
- Visit external Ko-fi link.
- Visit external support/privacy/credits links.

The app should remain fully usable offline after installation.

## 42. App Store / Legal / Support Documents

Assume app store-facing legal/support materials are required because the app supports optional crash reports/analytics after a crash.

Developer/release owner should prepare:

- Public privacy policy URL.
- Support page or support contact.
- App store privacy/data safety declarations.
- Terms only if needed.

Privacy policy should accurately describe:

- Local-only user data.
- Optional crash report behavior.
- No accounts.
- No cloud sync.
- No recording.
- No microphone access.
- No AI prompts/coaching.
- External Ko-fi donation link.

## 43. Accessibility Requirements

v1 should support accessibility basics:

- Large text / dynamic type compatibility.
- Screen reader labels for buttons, prompts, timers, and navigation.
- Sufficient contrast in light and dark themes.
- Reduced-motion behavior where applicable.
- Touch targets large enough for comfortable use.
- Timer/progress information available to screen readers.
- Prompt text readable without relying on color alone.

Hands-Free Mode should not be considered a substitute for screen reader accessibility.

## 44. Tablet Support

Tablets should be supported with tablet-friendly layouts.

Do not simply scale the phone UI.

Tablet layouts should use:

- Wider cards.
- Better spacing.
- Centered drill controls.
- Potential split-pane layouts for History/Journal where appropriate.
- Comfortable reading/tapping sizes.

## 45. Localization

v1 is English-only.

Requirements:

- English UI.
- English prompt libraries.
- No localization framework required for v1.
- No multilingual prompt support planned for v1.

## 46. Data Model — Required Developer Deliverable

Developer must provide a concrete local data schema before implementation.

At minimum, define models/tables for:

### PromptCategory

- id
- name
- built-in category flag or enum

### BuiltInPrompt

- id
- category id
- text
- content version/source metadata if needed

### CustomPrompt

- id
- category id
- text
- createdAt
- updatedAt

### DrillSettings

- drill id/name
- timer durations
- regroup durations where applicable
- prompt category selections
- hands-free default for that drill/session configuration if applicable
- drill-specific options
- updatedAt

### PracticeSession

- id
- drill id/name
- startedAt
- durationSeconds
- completed/loggedAt

### JournalEntry

- id
- date/createdAt
- updatedAt
- optional drill tag
- body text

### AppPreferences

- theme preference
- TTS voice
- TTS rate
- other app-level preferences

### ExportMetadata

- schemaVersion
- appVersion
- exportedAt

The developer may alter exact fields as needed but must document the final schema.

## 47. Automated Testing Requirements

Automated tests are required for core logic.

### Local Data Tests

Test:

- Custom prompt create/edit/delete.
- Custom prompt category assignment.
- Custom prompt validation.
- Broad slur blocking.
- Narrow explicit-sexual-content blocking.
- Rejected prompt not saved.
- Rejected prompt not logged.
- Saved drill settings persist locally.
- Reset Drill Defaults preserves history/journal/custom prompts.
- Reset All Data clears expected local data.

### Export / Import Tests

Test:

- JSON export includes expected data.
- JSON export excludes transient state and blocked prompt attempts.
- Import merges data.
- Import skips duplicates.
- Unsupported future schema version is rejected.
- Supported older schema version migrates correctly.
- Current schema version imports correctly.

### Drill Timing Tests

Test:

- Cat/Clock loop timing.
- Cat/Clock regroup behavior.
- Two-Character Scenes loop timing.
- A-to-C interval options.
- Five Line Game optional auto-advance.
- Pause/resume freezes timers and prompt changes.
- Stop confirmation behavior.
- Sessions under 30 seconds are not logged.
- Sessions at/over 30 seconds are logged.

### Character Creation Tests

Test:

- Default 2-character cycle.
- Configurable character count up to approximately 5.
- 60/90/120 second segment options.
- Cycle duration scales correctly.
- First-pass labels.
- Return-pass labels.
- Generate Prompt button only on first passes in normal mode.
- No review list.
- Hands-Free automatic prompt generation on first passes.
- Hands-Free return pass announces only “Character N.”

### Hands-Free / TTS Tests

Test:

- Prompt reading replaces “begin.”
- Timer announcements only for segments longer than 30 seconds.
- No timer announcements for exactly 30-second segments.
- Regroup stays silent.
- A-to-C default 30-second prompts read without timer announcements.
- Pause suppresses announcements.
- Resume continues correctly.

## 48. Acceptance Criteria Summary

A v1 build is acceptable when:

- User can open app with no account and immediately choose a drill.
- All five drills work according to their configured defaults.
- Drill settings can be changed and persist locally.
- Prompt system supports built-in local prompts plus user-created prompts.
- Custom prompts can be added, edited, deleted, and validated on-device.
- Hands-Free Mode works with correct TTS rules.
- Practice History records qualifying sessions silently.
- History dashboard shows summary stats and recent 20 sessions.
- Journal supports create/edit/delete and drill/date tagging.
- Tools section includes Prompt Generator, Timer, Emotion Wheel, and Journal.
- Settings include Appearance, TTS, Drill Defaults reset, Data Backup, Privacy/About, Support, and Donate.
- JSON export/import works with merge, duplicate skipping, schema versioning, and migration behavior.
- App is fully usable offline after installation.
- No microphone permission is requested.
- No audio recording exists.
- No push/local notifications exist.
- Optional crash reporting is user-triggered only and excludes user-created content.
- App supports iOS, Android, phones, and tablet-friendly layouts.
- Accessibility basics are implemented.
- No AI-generated prompts or AI coaching exist.

## 49. Future / Separate Work Items

These are separate from the core developer implementation spec:

1. Prompt list research and authoring.
2. Emotion wheel content design/licensing/original authoring.
3. Visual design palette and typography.
4. App icon and subtle mascot/branding exploration.
5. Privacy policy and support page drafting.
6. App store listing copy.
7. QA on real iOS and Android devices.

## 50. Open Questions for Later

These do not block v1 functional specification, but should be decided later:

- Exact visual style, colors, typography, and icon.
- Exact wording of each drill’s info/help page.
- Final prompt list size per category.
- Final emotion wheel taxonomy.
- Exact Ko-fi/support URLs.
- Exact crash-report provider, if any.
- Final local database/storage library.
- Exact tablet layout breakpoints.

