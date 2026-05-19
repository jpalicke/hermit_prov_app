# Hermit Prov — Open Issues at Handoff

These are the known gaps as of the v1 handoff. All items have GitHub issues on the `jpalicke/hermit_prov_app` repo.

---

## Issue #1 — Wire Up Crash Reporting

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/1  
**Priority:** Medium (should be fixed before v1 launch)

**What's there:** `lib/domain/crash/`, `lib/data/crash/no_op_crash_report_service.dart`, and `lib/features/crash/crash_report_dialog.dart` all exist and are correct.

**What's missing:** The crash service is not in `AppServices` DI. `main.dart` has no `FlutterError.onError` or `runZonedGuarded`. The dialog will never fire.

**How to fix:**
1. In `lib/core/di/app_services.dart`: add `CrashReportService` property; wire `NoOpCrashReportService` in `withLocalStorage()` and `withInMemory()`
2. In `lib/main.dart`: wrap `runApp` in `runZonedGuarded`; add `FlutterError.onError` that calls the service
3. Tests: add a widget test that confirms the crash dialog appears when the error handler fires

---

## Issue #2 — Android Release Signing

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/2  
**Priority:** Blocker for Play Store submission

**What's wrong:** `android/app/build.gradle.kts` release config uses the debug keystore:

```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")  // TODO: Add your own signing config
```

**How to fix (requires developer action — cannot be done in code alone):**
1. Generate a production keystore: `keytool -genkey -v -keystore hermit_prov_release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias hermit_prov`
2. Store the keystore file somewhere safe (NOT in the repo)
3. Create `android/key.properties` (gitignored) with the keystore path, password, and alias
4. Update `build.gradle.kts` to read from `key.properties` for release config
5. Verify `android/key.properties` is in `.gitignore`

---

## Issue #3 — DEVELOPER_NOTES.md Stale Entries

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/3  
**Priority:** Low (documentation only; doesn't affect the app)

Four stale entries in `DEVELOPER_NOTES.md`:

1. **`tts_voice` SharedPreferences key** — TTS voice selection was cut during development; only speaking rate remains. The `tts_voice` key reference should be removed.
2. **Backup schema `ttsVoice?` field** — `AppPreferences` no longer has this field; the backup schema doc still lists it.
3. **Manual QA checklist** — Contains "verify available system voices are listed" — that feature was removed.
4. **Crash report description** — States crash dialog fires on fatal exceptions; it is not wired up (see issue #1).

---

## Issue #4 — todo.md Milestone Completion State

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/4  
**Priority:** Low (documentation only; doesn't affect the app)

`todo.md` milestone checkboxes have not been kept fully current with the actual implementation state:

- Milestones 5–26: Many items are implemented but not ticked
- Milestone 3.1: Lists 6 prompt categories — the app has 8 (`PromptCategory` enum: objects, locations, relationships, occupations, emotions, activities, genre, events) with 1,661 total built-in prompts
- Milestone 3.6: TTS voice selection is listed as in-scope but was removed; only speaking rate remains

---

## Issue #5 — Tablet / iPad Layout Decision

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/5  
**Priority:** Must decide before v1 launch

**Current state:** All screens are single-column mobile layouts. There are no `MediaQuery` or `LayoutBuilder` breakpoints anywhere. iOS `Info.plist` allows all orientations on iPad.

**Decision needed:** Either implement a responsive two-column layout for tablets (≥600dp), or explicitly descope and constrain to portrait-phone layout for v1.

---

## Not Issues — Intentional Decisions

These might look like gaps but are intentional:

| Item | Decision |
|------|---------|
| No crash backend (Firebase, Sentry, etc.) | The app is privacy-first. The current architecture supports adding a backend later; `NoOpCrashReportService` is a drop-in placeholder. |
| Practice history not included in backup | Sessions are non-critical metadata. Excluding them keeps backup files small and reduces import complexity. |
| No pagination on history screen | Acceptable for v1; the history list is bounded in practice by real usage. |
| No stream / reactive state (Riverpod, BLoC) | Deliberate. The app's data flows are simple enough that `StatefulWidget` + direct repo calls is sufficient. Do not add a state management package without explicit discussion. |
| Five Line Scenes manual mode has no session logging | By design — manual mode has no timer, so there's nothing to log. |
