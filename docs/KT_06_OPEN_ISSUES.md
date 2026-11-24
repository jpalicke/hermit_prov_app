# Hermit Prov — Open Issues

Known gaps and in-progress items. All items have GitHub issues on the `jpalicke/hermit_prov_app` repo.

---

## Issue #1 — Crash Reporting Has No Backend

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/1  
**Priority:** Low (privacy-first app; adding a crash backend requires careful decision)

Crash handling is wired up: `main.dart` sets `FlutterError.onError` and `runZonedGuarded`, and `AppServices` provides `crashReportService`. The service is `NoOpCrashReportService`, so the dialog appears but reports go nowhere. Choosing a backend (or keeping it local-only) is still open. See `KT_02_ARCHITECTURE.md` for details.

---

## Issue #2 — Android Release Signing

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/2  
**Priority:** Resolved for CI; local builds still need `key.properties`

**CI status:** The `android-release.yml` workflow builds a signed AAB and submits to Play Store using keystore credentials stored as GitHub secrets (`KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`). CI release builds are fully signed.

**Local builds:** `android/app/build.gradle.kts` reads signing config from `android/key.properties`. This file is gitignored. To build a signed release locally:
1. Create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
2. Ensure the file is NOT committed

---

## Issue #5 — Tablet / iPad Layout Decision

**GitHub:** https://github.com/jpalicke/hermit_prov_app/issues/5  
**Priority:** Must decide before v1 launch

**Current state:** All screens are single-column mobile layouts. There are no `MediaQuery` or `LayoutBuilder` breakpoints anywhere. iOS `Info.plist` allows all orientations on iPad.

**Decision needed:** Either implement a responsive two-column layout for tablets (≥600dp), or explicitly descope and constrain to portrait-phone layout for v1.

---

## Release Status (v1.0.1+3)

**iOS App Store:** Submitted for review (2026-05-27). Awaiting Apple approval.
- Privacy policy live at `https://jpalicke.github.io/hermit_prov_app/privacy.html`
- Screenshots captured via `screenshots.yml` — see `docs/KT_09_SCREENSHOTS_WORKFLOW.md`

**Android Play Store:** Not yet submitted. Requires:
1. Keystore generation and `scripts/android_secrets.sh` to encode it
2. 5 GitHub secrets added (see `docs/KT_08_ANDROID_SIGNING_SETUP.md`)
3. App created in Play Console
4. Google Cloud service account with Play access
5. One manual AAB upload to bootstrap the listing

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
