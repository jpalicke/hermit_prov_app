// ABOUTME: Domain model for the Character Creation drill cycle structure.
// ABOUTME: Builds ordered segments: first pass for each character then return pass for each.

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

/// Metadata carried on each Character Creation segment.
enum CharacterCreationPassType {
  /// The performer develops the character for the first time.
  firstPass,

  /// The performer returns to the character after all first passes.
  returnPass,
}

/// Builds the full segment list for one Character Creation cycle.
///
/// Cycle order for N characters:
///   [char1 first, char2 first, … charN first,
///    char1 return, char2 return, … charN return]
///
/// Each segment carries a [CharacterCreationPassType] label so the UI can
/// render the correct prompt controls.
class CharacterCreationCycleBuilder {
  const CharacterCreationCycleBuilder();

  // ── Validation ─────────────────────────────────────────────────────────────

  /// Returns true when [characterCount] is within the allowed range (2–5).
  static bool isValidCharacterCount(int count) =>
      CharacterCreationSettings.allowedCharacterCounts.contains(count);

  /// Returns true when [duration] is one of the allowed segment durations.
  static bool isValidSegmentDuration(Duration duration) =>
      CharacterCreationSettings.allowedSegmentDurations.contains(duration);

  /// Clamps [count] to the nearest allowed value (2–5).
  static int clampCharacterCount(int count) {
    const min = 2;
    const max = 5;
    if (count < min) return min;
    if (count > max) return max;
    return count;
  }

  // ── Cycle building ─────────────────────────────────────────────────────────

  /// Builds the full ordered segment list for the given [settings].
  ///
  /// Throws [ArgumentError] if settings contain invalid values.
  List<DrillSegment> buildCycle(CharacterCreationSettings settings) {
    if (!isValidCharacterCount(settings.characterCount)) {
      throw ArgumentError(
        'Invalid character count: ${settings.characterCount}. '
        'Allowed: ${CharacterCreationSettings.allowedCharacterCounts}',
      );
    }
    if (!isValidSegmentDuration(settings.segmentDuration)) {
      throw ArgumentError(
        'Invalid segment duration: ${settings.segmentDuration}. '
        'Allowed: ${CharacterCreationSettings.allowedSegmentDurations}',
      );
    }

    final segments = <DrillSegment>[];

    // First passes.
    for (var i = 0; i < settings.characterCount; i++) {
      segments.add(
        DrillSegment(
          id: 'first_${i + 1}',
          type: DrillSegmentType.timed,
          duration: settings.segmentDuration,
          label: _firstPassLabel(i + 1),
          // promptPayload left null — the UI generates prompts on demand.
        ),
      );
    }

    // Return passes.
    for (var i = 0; i < settings.characterCount; i++) {
      segments.add(
        DrillSegment(
          id: 'return_${i + 1}',
          type: DrillSegmentType.timed,
          duration: settings.segmentDuration,
          label: _returnPassLabel(i + 1),
        ),
      );
    }

    return segments;
  }

  /// Total session duration for [settings].
  Duration totalDuration(CharacterCreationSettings settings) =>
      settings.segmentDuration * (settings.characterCount * 2);

  // ── Pass-type helpers ──────────────────────────────────────────────────────

  /// Returns the pass type for [segmentId] (one of 'first_N' or 'return_N').
  static CharacterCreationPassType passTypeForId(String segmentId) {
    if (segmentId.startsWith('first_')) return CharacterCreationPassType.firstPass;
    if (segmentId.startsWith('return_')) return CharacterCreationPassType.returnPass;
    throw ArgumentError('Unrecognised segment id: $segmentId');
  }

  /// The 1-based character number for the given segment id.
  static int characterNumberForId(String segmentId) {
    final parts = segmentId.split('_');
    return int.parse(parts.last);
  }

  // ── Label helpers ──────────────────────────────────────────────────────────

  static String _firstPassLabel(int characterNumber) =>
      'Character $characterNumber';

  static String _returnPassLabel(int characterNumber) =>
      'Return to Character $characterNumber';
}
