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
      test('drillId is DrillId.catClock', () {
        expect(const CatClockSettings().drillId, DrillId.catClock);
      });

      test('speaking duration is 3 minutes', () {
        expect(
          const CatClockSettings().speakingDuration,
          const Duration(minutes: 3),
        );
      });

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
      test('drillId is DrillId.characterCreation', () {
        expect(const CharacterCreationSettings().drillId, DrillId.characterCreation);
      });

      test('character count defaults to 2', () {
        expect(const CharacterCreationSettings().characterCount, 2);
      });

      test('segment duration defaults to 60 seconds', () {
        expect(
          const CharacterCreationSettings().segmentDuration,
          const Duration(seconds: 60),
        );
      });

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

      test('allowed character counts are 2, 3, 4, 5', () {
        expect(CharacterCreationSettings.allowedCharacterCounts, [2, 3, 4, 5]);
      });
    });

    // ── Two-Character Scenes ─────────────────────────────────────────────────

    group('Two-Character Scenes', () {
      test('drillId is DrillId.twoCharacterScenes', () {
        expect(const TwoCharacterScenesSettings().drillId, DrillId.twoCharacterScenes);
      });

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
      test('drillId is DrillId.atoC', () {
        expect(const AtoCSettings().drillId, DrillId.atoC);
      });

      test('default interval is 30 seconds', () {
        expect(const AtoCSettings().interval, const Duration(seconds: 30));
      });

      test('prompt source defaults to word bucket', () {
        expect(const AtoCSettings().promptCategories, PromptCategory.wordBucket);
      });

      test('loops until stopped', () {
        expect(const AtoCSettings().loopsUntilStopped, isTrue);
      });

      test('allowed intervals are 15, 30, 45, 60 seconds', () {
        expect(AtoCSettings.allowedIntervals, [
          const Duration(seconds: 15),
          const Duration(seconds: 30),
          const Duration(seconds: 45),
          const Duration(seconds: 60),
        ]);
      });
    });

    // ── Five Line Game Drill ─────────────────────────────────────────────────

    group('Five Line Game Drill', () {
      test('drillId is DrillId.fiveLineGame', () {
        expect(const FiveLineGameSettings().drillId, DrillId.fiveLineGame);
      });

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
  });
}
