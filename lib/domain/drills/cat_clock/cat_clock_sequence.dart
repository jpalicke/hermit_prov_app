// ABOUTME: Builds the repeating segment sequence for the Cat/Clock drill.
// ABOUTME: Each rep is a speaking segment followed by a regroup segment.

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

/// Builds one loop's worth of segments for the Cat/Clock drill.
///
/// The drill loops indefinitely until the user stops it.  Each loop consists
/// of a speaking segment (with two prompt slots) followed by a regroup
/// segment.
class CatClockSequence {
  const CatClockSequence();

  /// Creates the two-segment sequence for one rep using [settings].
  ///
  /// [prompt1] and [prompt2] are the text prompts for the speaking segment.
  /// They may be null if no prompt could be selected.
  List<DrillSegment> buildRep({
    required CatClockSettings settings,
    String? prompt1,
    String? prompt2,
    int repIndex = 0,
  }) {
    // Build payload by filtering out null prompts before joining.
    final parts = <String>[
      // ignore: use_null_aware_elements, Dart SDK version constraint prevents use of null-aware elements (?x syntax requires Dart 3.8+).
      if (prompt1 != null) prompt1,
      // ignore: use_null_aware_elements, Dart SDK version constraint prevents use of null-aware elements (?x syntax requires Dart 3.8+).
      if (prompt2 != null) prompt2,
    ];
    final promptPayload = parts.join('\n');

    return [
      DrillSegment(
        id: 'speaking_$repIndex',
        type: DrillSegmentType.speaking,
        duration: settings.speakingDuration,
        promptPayload: promptPayload.isEmpty ? null : promptPayload,
        label: 'Speak',
      ),
      DrillSegment(
        id: 'regroup_$repIndex',
        type: DrillSegmentType.regroup,
        duration: settings.regroupDuration,
        label: 'Regroup',
      ),
    ];
  }
}
