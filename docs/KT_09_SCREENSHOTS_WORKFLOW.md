# Hermit Prov — App Store Screenshots Workflow

## Overview

The `screenshots.yml` workflow captures App Store screenshots automatically using iOS Simulator and an integration test. It runs on `workflow_dispatch` only (manual trigger).

```bash
gh workflow run screenshots.yml --repo jpalicke/hermit_prov_app
```

Screenshots are uploaded as a workflow artifact with 90-day retention.

---

## How It Works

The workflow coordinates between two processes running in parallel:

1. **`flutter drive`** — runs the integration test (`integration_test/screenshots_test.dart`) on the simulator. The test navigates to each screen and writes a `${name}_ready` sentinel file to the app's tmp directory when it's ready for a screenshot.

2. **The CI shell script** — polls for each sentinel file, takes a screenshot with `xcrun simctl io screenshot`, then writes a `${name}_done` sentinel to unblock the test and let it navigate to the next screen.

This sentinel handshake ensures screenshots are taken at exactly the right moment, not mid-animation.

---

## Output Sizes

App Store Connect requires screenshots at specific dimensions. The workflow produces two sets:

| Folder | Dimensions | How produced |
|--------|-----------|-------------|
| `6.9in/` | 1320 × 2868 px | Captured natively on iPhone 17 Pro Max |
| `6.5in/` | 1284 × 2778 px | Resized from 6.9" captures using `sips` |

**Why sips for 6.5"?** The macos-26 GitHub Actions runner (Xcode 26) only ships iPhone 17-series simulators. None of them produce 6.5" dimensions natively — iPhone Air outputs 1260×2736, which App Store Connect does not accept. Resizing the 6.9" captures with `sips` is the workaround.

If Apple ever ships a macos runner with a simulator that natively produces 1284×2778, the sips step can be replaced with a second `capture_device` call.

---

## Screens Captured (5 total)

| File | Screen |
|------|--------|
| `01_practice_home.png` | Practice tab — the drill list |
| `02_five_line_configure.png` | Five Line Scenes configure screen |
| `03_five_line_session.png` | Five Line Scenes session screen |
| `04_tools.png` | Tools screen |
| `05_suggestion_generator.png` | Suggestion Generator with a prompt showing |

---

## Uploading to App Store Connect

In App Store Connect, upload:
- `6.9in/` screenshots to the **6.9-inch display** slot
- `6.5in/` screenshots to the **6.5-inch display** slot

Each slot accepts up to 10 screenshots. Only the first is shown by default in search results; order them intentionally.

---

## Integration Test Details

**File:** `integration_test/screenshots_test.dart`

The test uses `AppServices.withLocalStorage()` — real SQLite, not in-memory. This means:
- The configure screen (`02_five_line_configure`) waits for SQLite to load settings before capturing. The test includes an explicit `pump(2s)` + `pumpAndSettle()` to allow the async `_load()` to complete.
- Tap targets that could be obscured by the bottom nav bar use both `scrollUntilVisible` and `ensureVisible` before tapping.
- The configure screen uses `PopScope(canPop: false)`, so back navigation is done by tapping the keyed Save button (`Key('drill_configure_save_button')`) rather than `pageBack()`.

**Widget keys used by the test:**

| Key | Widget |
|-----|--------|
| `drill_card_configure_fiveLineGame` | Configure gear icon on Five Line card |
| `drill_configure_save_button` | Save button on configure screen |
| `drill_card_start_fiveLineGame` | Five Line card tap target |
| `tools_card` | Tools card tap target |
| `tool_tile_suggestion_generator` | Suggestion Generator list tile |
| `new_suggestion_button` | New Suggestion button |

---

## Troubleshooting

**"flutter drive exited before sentinel appeared"** — flutter drive crashed during Xcode build or app launch. Check the flutter drive log artifact uploaded on failure. Usually a transient CI issue; re-run the workflow.

**Timed out waiting for sentinel** — the test got stuck. Most likely cause: a widget key is missing or a screen took longer than expected to settle. Check the flutter drive logs.

**Wrong screenshot dimensions** — verify the `sips` command output in the CI logs. The resize step logs "Generated 6.5in screenshots (1284x2778) via sips." If that line is absent, the resize step didn't run.
