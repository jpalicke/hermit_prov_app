# Gotchas

Lessons learned from corrections. Each entry is a strict rule to prevent the same category of error.

---

## Integration tests must be wired into CI, not just written

**Rule:** When integration tests are written, immediately verify they are invoked in every relevant CI workflow. Writing the test file is not done until it runs in CI.

**Why:** Integration tests for hermit_prov_app existed in `integration_test/app_test.dart` but were never added to `ios_unsigned.yml` or `ios-release.yml`. They ran locally only. Joe P had explicitly asked for automated verification and this was missed.

**How to apply:** After writing or reviewing any test file under `integration_test/`, open every `.github/workflows/*.yml` and confirm there is a step that runs it. If not, add one before closing the task.
