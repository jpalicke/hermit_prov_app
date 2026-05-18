// ABOUTME: Sealed class hierarchy for per-drill settings with built-in defaults.
// ABOUTME: Each subclass covers one drill's configurable options and allowed values.
//
// Usage pattern: switch (settings) { case CatClockSettings s: ... }
// The sealed keyword enforces exhaustive switches at compile time.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

sealed class DrillSettings {
  const DrillSettings();

  DrillId get drillId;

  /// Whether this drill repeats indefinitely until the user manually stops it.
  /// False for Character Creation (ends after the cycle) and Five Line Game
  /// (manual tap or explicit auto-advance session).
  bool get loopsUntilStopped;

  /// Returns the factory-default [DrillSettings] for [drillId].
  /// Repositories use this to return defaults before any settings are saved.
  static DrillSettings defaultsFor(DrillId drillId) => switch (drillId) {
        DrillId.catClock => const CatClockSettings(),
        DrillId.characterCreation => const CharacterCreationSettings(),
        DrillId.twoCharacterScenes => const TwoCharacterScenesSettings(),
        DrillId.atoC => const AtoCSettings(),
        DrillId.fiveLineGame => const FiveLineGameSettings(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────

final class CatClockSettings extends DrillSettings {
  const CatClockSettings({
    this.speakingDuration = const Duration(minutes: 3),
    this.regroupDuration = const Duration(seconds: 30),
    this.prompt1Categories = const [PromptCategory.objects],
    this.prompt2Categories = const [PromptCategory.objects],
  });

  final Duration speakingDuration;
  final Duration regroupDuration;
  final List<PromptCategory> prompt1Categories;
  final List<PromptCategory> prompt2Categories;

  @override
  DrillId get drillId => DrillId.catClock;

  @override
  bool get loopsUntilStopped => true;
}

// ─────────────────────────────────────────────────────────────────────────────

final class CharacterCreationSettings extends DrillSettings {
  const CharacterCreationSettings({
    this.characterCount = 2,
    this.segmentDuration = const Duration(seconds: 60),
    this.promptCategories = PromptCategory.wordBucket,
  });

  final int characterCount;
  final Duration segmentDuration;
  final List<PromptCategory> promptCategories;

  @override
  DrillId get drillId => DrillId.characterCreation;

  @override
  bool get loopsUntilStopped => false;

  static const List<Duration> allowedSegmentDurations = [
    Duration(seconds: 60),
    Duration(seconds: 90),
    Duration(seconds: 120),
  ];

  /// Valid character counts. The drill supports 2–5 characters per session.
  static const List<int> allowedCharacterCounts = [2, 3, 4, 5];
}

// ─────────────────────────────────────────────────────────────────────────────

final class TwoCharacterScenesSettings extends DrillSettings {
  const TwoCharacterScenesSettings({
    this.sceneDuration = const Duration(seconds: 90),
    this.regroupDuration = const Duration(seconds: 30),
    this.promptCategories = PromptCategory.wordBucket,
  });

  final Duration sceneDuration;
  final Duration regroupDuration;
  final List<PromptCategory> promptCategories;

  @override
  DrillId get drillId => DrillId.twoCharacterScenes;

  @override
  bool get loopsUntilStopped => true;
}

// ─────────────────────────────────────────────────────────────────────────────

final class AtoCSettings extends DrillSettings {
  const AtoCSettings({
    this.interval = const Duration(seconds: 30),
    this.promptCategories = PromptCategory.wordBucket,
  });

  final Duration interval;
  final List<PromptCategory> promptCategories;

  @override
  DrillId get drillId => DrillId.atoC;

  @override
  bool get loopsUntilStopped => true;

  static const List<Duration> allowedIntervals = [
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 45),
    Duration(seconds: 60),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────

final class FiveLineGameSettings extends DrillSettings {
  const FiveLineGameSettings({
    this.autoAdvance = false,
    this.autoAdvanceInterval,
    this.promptCategories = PromptCategory.wordBucket,
  });

  final bool autoAdvance;

  /// Only meaningful when [autoAdvance] is true. Null means the user has not
  /// yet configured an interval; consumers should default to
  /// [allowedAutoAdvanceIntervals.first] (30 seconds) when this is null.
  final Duration? autoAdvanceInterval;
  final List<PromptCategory> promptCategories;

  @override
  DrillId get drillId => DrillId.fiveLineGame;

  @override
  bool get loopsUntilStopped => false;

  static const List<Duration> allowedAutoAdvanceIntervals = [
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 90),
  ];
}
