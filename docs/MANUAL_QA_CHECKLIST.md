# ABOUTME: Manual QA checklist for Hermit Prov.
# ABOUTME: Update this file whenever new features are added or flows change.

# Hermit Prov — Manual QA Checklist

Run this checklist on a real device before any App Store submission or major release.
Automated tests (unit, widget, integration) cover logic and golden paths but cannot
catch visual polish, feel, TTS audio output, or real-device platform behavior.

Mark each item [ ] not tested, [x] pass, or [!] fail with a note.

---

## 1. Launch and Navigation

- [ ] App launches without crash
- [ ] Opens directly to Practice tab (no onboarding)
- [ ] Bottom nav switches to History tab
- [ ] Bottom nav switches to Settings tab
- [ ] Bottom nav switches back to Practice tab
- [ ] No visual glitches on tab switch

---

## 2. Practice Home

- [ ] All 5 drill cards visible: Cat/Clock, Character Creation, Two-Character Scenes, A-to-C / Bad Idea / Initiation, Five Line Game Drill
- [ ] Tools card visible below drill cards
- [ ] Each card shows name and subtitle
- [ ] Tapping each drill card navigates to that drill's start screen
- [ ] Tapping Tools navigates to the Tools screen
- [ ] Back navigation returns to Practice Home from each drill start screen

---

## 3. Cat/Clock Drill

**Start screen**
- [ ] Shows drill name, Start, Configure, and info button

**Configure screen**
- [ ] Speaking duration can be changed
- [ ] Regroup duration can be changed
- [ ] Prompt 1 category can be changed
- [ ] Prompt 2 category can be changed
- [ ] Hands-Free toggle is present
- [ ] Save persists settings (verify by re-opening Configure)

**Session**
- [ ] Two prompts display at session start
- [ ] Countdown ring and timer visible
- [ ] Regroup segment is visually distinct from speaking segment
- [ ] New prompts appear after regroup
- [ ] Pause button freezes timer and prompt
- [ ] Resume button continues correctly
- [ ] Stop button shows confirmation dialog
- [ ] Cancelling stop dialog resumes session
- [ ] Confirming stop returns to Cat/Clock start screen

**Hands-Free**
- [ ] Enable Hands-Free in Configure
- [ ] Both prompts announced aloud at segment start
- [ ] "30 seconds" announced at 30s remaining
- [ ] "10 seconds" announced at 10s remaining
- [ ] Pausing suppresses announcements
- [ ] Stop silences TTS immediately

---

## 4. Two-Character Scenes Drill

- [ ] One prompt displays at scene start
- [ ] No character speaker labels visible
- [ ] Regroup segment shows no prompt
- [ ] New prompt appears after regroup
- [ ] Configure saves scene and regroup durations
- [ ] Pause/Resume works
- [ ] Stop confirmation works

---

## 5. A-to-C / Bad Idea / Initiation Drill

- [ ] One prompt displays, changes every 30 seconds by default
- [ ] Countdown/progress visible for current interval
- [ ] Configure saves interval selection (15/30/45/60s)
- [ ] Pause freezes prompt and timer
- [ ] Resume continues correctly
- [ ] Stop confirmation works

---

## 6. Five Line Game Drill

**Manual mode (default)**
- [ ] One prompt displayed, no timer
- [ ] New Prompt button generates a new prompt
- [ ] No line labels or structural labels visible

**Auto-advance mode**
- [ ] Countdown/progress visible
- [ ] Prompt changes automatically at selected interval
- [ ] Pause/Resume works
- [ ] Stop confirmation works

**Configure**
- [ ] Auto-advance toggle saves
- [ ] Interval selection saves (30/60/90s)
- [ ] Category source saves

---

## 7. Character Creation Drill

**Configure**
- [ ] Character count (1-5) saves
- [ ] Segment duration (60/90/120s) saves
- [ ] Prompt category saves

**Session — normal mode**
- [ ] "Character 1" label on first pass
- [ ] Generate Prompt button visible on first passes only
- [ ] Tapping Generate Prompt shows a prompt for that character
- [ ] "Return to Character N" label on return passes
- [ ] No prompt shown on return passes
- [ ] No character list or review button visible
- [ ] Session ends after the full cycle and returns to start screen
- [ ] Pause/Resume works
- [ ] Stop confirmation works

---

## 8. Tools — Prompt Generator

- [ ] Reachable from Tools screen
- [ ] New Prompt button generates a prompt
- [ ] Category chips change the eligible prompt pool
- [ ] Word Bucket selection draws from all categories
- [ ] Auto-advance toggle enables countdown
- [ ] Auto-advance generates new prompt at interval
- [ ] Auto-advance stops when leaving the screen (no leak)

---

## 9. Tools — Timer

- [ ] Reachable from Tools screen
- [ ] Simple countdown: set duration, start, runs to zero
- [ ] Interval mode: work time alternates with rest time
- [ ] Pause/Resume works
- [ ] Stop/Reset works
- [ ] Timer tool usage does not appear in Practice History

---

## 10. Tools — Emotion Wheel

- [ ] Reachable from Tools screen
- [ ] Broad emotion categories visible as arcs
- [ ] Tapping a broad category reveals specific emotions
- [ ] Tapping a specific emotion shows it as selected
- [ ] No "send to drill" action present
- [ ] Pinch-to-zoom works

---

## 11. History

- [ ] History tab shows after completing a 30s+ drill session
- [ ] Practice Stats section shows: total time, sessions, current streak, longest streak
- [ ] Drill breakdown visible
- [ ] Recent sessions list shows up to 20 sessions
- [ ] Sessions under 30 seconds do not appear
- [ ] Standalone tool usage does not appear
- [ ] No individual session delete control

---

## 12. Journal

**Access**
- [ ] Reachable from History tab
- [ ] Reachable from Tools screen

**CRUD**
- [ ] Create new entry with body text
- [ ] Optional drill tag can be set
- [ ] Entry appears in list with date and preview
- [ ] Tap entry to edit it
- [ ] Edited text saves correctly
- [ ] Delete entry via delete button (with confirmation)
- [ ] List sorts newest-first
- [ ] Empty state shows when no entries exist

---

## 13. Settings

**Appearance**
- [ ] Light theme applies immediately
- [ ] Dark theme applies immediately
- [ ] System theme follows device setting

**Text-to-Speech**
- [ ] Speaking rate setting saves
- [ ] Voice setting (if available) saves

**Drill Defaults**
- [ ] Reset Drill Defaults shows confirmation dialog
- [ ] Confirming restores all drill timings and categories to defaults
- [ ] Custom prompts are preserved after Reset Drill Defaults
- [ ] Journal entries are preserved after Reset Drill Defaults
- [ ] Practice history is preserved after Reset Drill Defaults

**Reset All Data**
- [ ] Shows confirmation dialog
- [ ] Confirming deletes custom prompts, journal, history
- [ ] App preferences (theme, TTS) reset to defaults

**Data Backup**
- [ ] Export generates and shares a JSON file
- [ ] Backup warning about local-only data is visible
- [ ] Import accepts the exported JSON file
- [ ] Imported data merges correctly (no duplicates on double-import)
- [ ] Unsupported schema version shows a clear error message

**Privacy / About**
- [ ] Reachable from Settings
- [ ] No Recording assurance visible
- [ ] No account / no cloud sync statements present
- [ ] Unaffiliated disclaimer present

**Support / Donate**
- [ ] Support link opens email with pre-filled template
- [ ] Ko-fi link opens browser
- [ ] No donation prompt appears after any drill session

---

## 14. Permissions Audit

- [ ] No microphone permission requested
- [ ] No speech-recognition permission requested
- [ ] No notification permission requested
- [ ] No recording permission requested

---

## 15. Offline Behavior

- [ ] Airplane mode: app fully usable
- [ ] All drills run offline
- [ ] Prompt Generator runs offline
- [ ] Timer runs offline
- [ ] Emotion Wheel runs offline
- [ ] Journal works offline
- [ ] History works offline
- [ ] Settings work offline

---

## Notes

_Record any failures or observations here during a QA pass._

| Date | Tester | Item | Result | Notes |
|------|--------|------|--------|-------|
|      |        |      |        |       |
