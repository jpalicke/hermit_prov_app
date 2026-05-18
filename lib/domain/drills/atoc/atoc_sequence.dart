// ABOUTME: Domain logic for A-to-C / Bad Idea / Initiation drill segment building.
// ABOUTME: Each rep is a single timed segment; the drill loops indefinitely.

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

/// Builds one loop's worth of segments for the A-to-C drill.
///
/// Each rep is a single interval segment with a prompt.  The controller runs
/// in looping mode so it cycles forever until the user stops it.
class AtoCSequence {
  const AtoCSequence();

  /// Validates that [interval] is one of the allowed values.
  static bool isValidInterval(Duration interval) {
    return AtoCSettings.allowedIntervals.contains(interval);
  }

  /// Creates a single-segment rep for the given interval.
  List<DrillSegment> buildRep({
    required AtoCSettings settings,
    String? prompt,
    int repIndex = 0,
  }) {
    assert(
      isValidInterval(settings.interval),
      'Interval must be one of ${AtoCSettings.allowedIntervals}',
    );
    return [
      DrillSegment(
        id: 'interval_$repIndex',
        type: DrillSegmentType.timed,
        duration: settings.interval,
        promptPayload: prompt,
        label: 'Go',
      ),
    ];
  }
}
