// ABOUTME: Unit tests verifying default DrillSettings values for every drill.
// ABOUTME: Also tests allowed duration/interval constants, drillId getters, and looping behaviour.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

void main() {
  group('DrillSettings defaults', () {
    // ── Cat/Clock ────────────────────────────────────────────────────────────

    group('Cat/Clock', () {
      test('regroup duration is 30 seconds', () {
        expect(
          const CatClockSettings().regroupDuration,
          const Duration(seconds: 30),
        );
      });

      test('both prompt sources default to objects', () {
        expect(const CatClockSettings().prompt1Categories, [PromptCategory.objects]);
        expect(const CatClockSettings().prompt2Categories, [PromptCategory.objects]);
      });

      test('loops until stopped', () {
        expect(const CatClockSettings().loopsUntilStopped, isTrue);
      });
    });

    // ── Character Creation ───────────────────────────────────────────────────

    group('Character Creation', () {
      test('prompt source defaults to word bucket', () {
        expect(
          const CharacterCreationSettings().promptCategories,
          PromptCategory.wordBucket,
        );
      });

      test('does not loop — session ends after the cycle', () {
        expect(const CharacterCreationSettings().loopsUntilStopped, isFalse);
      });

      test('allowed segment durations are 60, 90, 120 seconds', () {
        expect(CharacterCreationSettings.allowedSegmentDurations, [
          const Duration(seconds: 60),
          const Duration(seconds: 90),
          const Duration(seconds: 120),
        ]);
      });
    });

    // ── Two-Character Scenes ─────────────────────────────────────────────────

    group('Two-Character Scenes', () {
      test('scene duration defaults to 90 seconds', () {
        expect(
          const TwoCharacterScenesSettings().sceneDuration,
          const Duration(seconds: 90),
        );
      });

      test('regroup duration defaults to 30 seconds', () {
        expect(
          const TwoCharacterScenesSettings().regroupDuration,
          const Duration(seconds: 30),
        );
      });

      test('prompt source defaults to word bucket', () {
        expect(
          const TwoCharacterScenesSettings().promptCategories,
          PromptCategory.wordBucket,
        );
      });

      test('loops until stopped', () {
        expect(const TwoCharacterScenesSettings().loopsUntilStopped, isTrue);
      });
    });

    // ── A-to-C / Bad Idea / Initiation ──────────────────────────────────────

    group('A-to-C / Bad Idea / Initiation', () {
      test('prompt source defaults to word bucket', () {
        expect(const AtoCSettings().promptCategories, PromptCategory.wordBucket);
      });

      test('loops until stopped', () {
        expect(const AtoCSettings().loopsUntilStopped, isTrue);
      });
    });

    // ── Five Line Scenes ─────────────────────────────────────────────────────

    group('Five Line Scenes', () {
      test('auto-advance is off by default', () {
        expect(const FiveLineGameSettings().autoAdvance, false);
      });

      test('auto-advance interval is null when auto-advance is off', () {
        expect(const FiveLineGameSettings().autoAdvanceInterval, isNull);
      });

      test('prompt source defaults to word bucket', () {
        expect(
          const FiveLineGameSettings().promptCategories,
          PromptCategory.wordBucket,
        );
      });

      test('does not loop — user taps for each new prompt', () {
        expect(const FiveLineGameSettings().loopsUntilStopped, isFalse);
      });

      test('allowed auto-advance intervals are 30, 60, 90 seconds', () {
        expect(FiveLineGameSettings.allowedAutoAdvanceIntervals, [
          const Duration(seconds: 30),
          const Duration(seconds: 60),
          const Duration(seconds: 90),
        ]);
      });
    });

    test('hands-free mode is off by default for every drill', () {
      for (final id in DrillId.values) {
        expect(
          DrillSettings.defaultsFor(id).handsFreeModeEnabled,
          isFalse,
          reason: '$id',
        );
      }
    });
  });
}
