#!/usr/bin/env bash
# Checks the CLAUDE.md rules that a machine can enforce. Run from the repo root.
# Used by .github/workflows/pr_checks.yml; safe to run locally.
set -uo pipefail

fail=0
error() { echo "::error::$1"; fail=1; }

# 1. Every hand-written Dart file starts with two "// ABOUTME: " lines.
while IFS= read -r f; do
  if [ "$(head -n 2 "$f" | grep -c '^// ABOUTME: ')" -ne 2 ]; then
    error "$f must start with two '// ABOUTME: ' comment lines"
  fi
done < <(git ls-files '*.dart' | grep -v '\.g\.dart$')

# 2. No mock frameworks, and no packages that break the product constraints
#    (ads, purchases, cloud, notifications, recording, speech recognition).
forbidden='mockito|mocktail|mocktail_image_network|google_mobile_ads|in_app_purchase|purchases_flutter|firebase_[a-z_]+|flutter_local_notifications|awesome_notifications|record|flutter_sound|speech_to_text|permission_handler'
if hits=$(grep -nE "^\s+(${forbidden}):" pubspec.yaml); then
  while IFS= read -r line; do error "pubspec.yaml has a forbidden package: $line"; done <<<"$hits"
fi

# 3. No microphone or notification permissions in the shipped Android manifest.
manifest=android/app/src/main/AndroidManifest.xml
if hits=$(grep -nE 'RECORD_AUDIO|POST_NOTIFICATIONS|SCHEDULE_EXACT_ALARM|USE_EXACT_ALARM' "$manifest"); then
  while IFS= read -r line; do error "$manifest requests a forbidden permission: $line"; done <<<"$hits"
fi

# 4. Every integration test is run by at least one workflow.
for t in integration_test/*_test.dart; do
  [ -e "$t" ] || continue
  if ! grep -qF "$t" .github/workflows/*.yml; then
    error "$t is not run by any .github/workflows/*.yml"
  fi
done

# 5. Tests live in the agreed folders.
while IFS= read -r f; do
  case "$f" in
    test/unit/*|test/widget/*|test/repository/*) ;;
    *) error "$f must live in test/unit/, test/widget/ or test/repository/" ;;
  esac
done < <(git ls-files 'test/*_test.dart')

if [ "$fail" -ne 0 ]; then
  echo "Project rule checks failed."
  exit 1
fi
echo "Project rule checks passed."
