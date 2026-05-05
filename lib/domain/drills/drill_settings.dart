// ABOUTME: Sealed class hierarchy for per-drill settings with built-in defaults.
// ABOUTME: Each subclass covers one drill's configurable options and allowed values.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

sealed class DrillSettings {
  const DrillSettings();

  DrillId get drillId;
}

// ─────────────────────────────────────────────────────────────────────────────

final class CatClockSettings extends DrillSettings {
  const CatClockSettings({
    this.speakingDuration = const Duration(minutes: 3),
    this.regroupDuration = const Duration(seconds: 30),
    this.prompt1Categories = PromptCategory.wordBucket,
    this.prompt2Categories = PromptCategory.wordBucket,
  });

  final Duration speakingDuration;
  final Duration regroupDuration;
  final List<PromptCategory> prompt1Categories;
  final List<PromptCategory> prompt2Categories;

  @override
  DrillId get drillId => DrillId.catClock;
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

  static const List<Duration> allowedSegmentDurations = [
    Duration(seconds: 60),
    Duration(seconds: 90),
    Duration(seconds: 120),
  ];
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
    this.autoAdvanceInterval = const Duration(seconds: 30),
    this.promptCategories = PromptCategory.wordBucket,
  });

  final bool autoAdvance;
  final Duration autoAdvanceInterval;
  final List<PromptCategory> promptCategories;

  @override
  DrillId get drillId => DrillId.fiveLineGame;

  static const List<Duration> allowedAutoAdvanceIntervals = [
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 90),
  ];
}
