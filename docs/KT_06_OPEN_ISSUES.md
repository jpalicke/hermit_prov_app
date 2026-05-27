# Hermit Prov — Open Issues

Known gaps and in-progress items. All items have GitHub issues on the `jpalicke/hermit_prov_app` repo.

---

## Issue #1 — Crash Reporting Not Wired Up

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/1  
**Priority:** Low (privacy-first app; adding a crash backend requires careful decision)

The crash reporting infrastructure exists (`CrashReportService` interface, `NoOpCrashReportService`, `CrashReportDialog`) but is not connected. `AppServices` does not include `CrashReportService`, and `main.dart` has no `FlutterError.onError` or `runZonedGuarded`. The crash dialog will never fire in production.

To wire it up: choose a backend (or keep it local-only), add to `AppServices`, and wrap `runApp` in `runZonedGuarded`.

---

## Issue #2 — Android Release Signing

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/2  
**Priority:** Resolved for CI; local builds still need `key.properties`

**CI status:** The `android-release.yml` workflow builds a signed AAB and submits to Play Store using keystore credentials stored as GitHub secrets (`KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`). CI release builds are fully signed.

**Local builds:** `android/app/build.gradle.kts` reads signing config from `android/key.properties`. This file is gitignored. To build a signed release locally:
1. Create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
2. Ensure the file is NOT committed

---

## Issue #3 — DEVELOPER_NOTES.md Stale Entries

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/3  
**Priority:** Low (documentation only)

`DEVELOPER_NOTES.md` has entries that reference implementation decisions that have since changed or been superseded. These should be reviewed and pruned or updated.

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

## Release Status (v1.0.1+3)

The app has been submitted to Apple App Store Connect. The following items are still needed to complete the App Store listing:

- Screenshots: captured via `screenshots.yml` workflow; need to be uploaded to App Store Connect
- App description, keywords, and support URL in App Store Connect
- Copyright field: "© 2026 Joseph Palicke"
- Support URL: `https://github.com/jpalicke/hermit_prov_app/issues`
- Privacy policy URL: `https://jpalicke.github.io/hermit_prov_app/privacy.html` (live)

Android Play Store submission is pending: requires adding 5 GitHub secrets, creating the app in Play Console, setting up a service account, and performing a first manual AAB upload.

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
