// ABOUTME: Unit tests verifying default DrillSettings values for every drill.
// ABOUTME: Also tests allowed duration/interval constants for each drill type.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

void main() {
  group('DrillSettings defaults', () {
    group('Cat/Clock', () {
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

      test('both prompt sources default to word bucket', () {
        expect(const CatClockSettings().prompt1Categories, PromptCategory.wordBucket);
        expect(const CatClockSettings().prompt2Categories, PromptCategory.wordBucket);
      });
    });

    group('Character Creation', () {
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

      test('allowed segment durations are 60, 90, 120 seconds', () {
        expect(CharacterCreationSettings.allowedSegmentDurations, [
          const Duration(seconds: 60),
          const Duration(seconds: 90),
          const Duration(seconds: 120),
        ]);
      });
    });

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
    });

    group('A-to-C / Bad Idea / Initiation', () {
      test('default interval is 30 seconds', () {
        expect(const AtoCSettings().interval, const Duration(seconds: 30));
      });

      test('prompt source defaults to word bucket', () {
        expect(const AtoCSettings().promptCategories, PromptCategory.wordBucket);
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

    group('Five Line Game Drill', () {
      test('auto-advance is off by default', () {
        expect(const FiveLineGameSettings().autoAdvance, false);
      });

      test('prompt source defaults to word bucket', () {
        expect(
          const FiveLineGameSettings().promptCategories,
          PromptCategory.wordBucket,
        );
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
