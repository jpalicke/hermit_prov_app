// ABOUTME: Builds the repeating segment sequence for the Two-Character Scenes drill.
// ABOUTME: Each rep is a timed scene segment followed by a regroup segment (no prompt during regroup).

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

/// Builds one loop's worth of segments for the Two-Character Scenes drill.
///
/// Each rep has a single scene segment (with one prompt) followed by a silent
/// regroup segment.  The drill loops indefinitely until stopped.
class TwoCharacterSequence {
  const TwoCharacterSequence();

  /// Creates the two-segment sequence for one rep.
  ///
  /// [prompt] is the scene prompt; may be null if none could be selected.
  List<DrillSegment> buildRep({
    required TwoCharacterScenesSettings settings,
    String? prompt,
    int repIndex = 0,
  }) {
    return [
      DrillSegment(
        id: 'scene_$repIndex',
        type: DrillSegmentType.speaking,
        duration: settings.sceneDuration,
        promptPayload: prompt,
        label: 'Scene',
      ),
      DrillSegment(
        id: 'regroup_$repIndex',
        type: DrillSegmentType.regroup,
        duration: settings.regroupDuration,
        // Regroup has no prompt — intentional per spec.
        label: 'Regroup',
      ),
    ];
  }
}
