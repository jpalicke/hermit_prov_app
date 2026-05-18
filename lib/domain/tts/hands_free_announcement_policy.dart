// ABOUTME: Domain class that drives TTS announcements during a hands-free drill session.
// ABOUTME: Pure Dart — no Flutter imports. Encapsulates all announcement timing rules.

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';

/// Drives TTS announcements based on segment transitions and countdown ticks.
///
/// Rules (in priority order):
///  1. Paused: no announcements.
///  2. Regroup segments: silent always.
///  3. Non-regroup with a promptPayload: speak prompt text on segment start.
///  4. Non-regroup without a prompt: silent on start (timer-only).
///  5. Segments longer than 30 s: announce at remaining == 30 s ("30 seconds"),
///     10 s ("10 seconds"), and 0 s ("time").
///  6. Segments exactly 30 s: no timer announcements.
///  7. Character Creation first-pass (label contains "Pass 1", "first",
///     "Character N"): speak "Character N: [prompt]" on start.
///  8. Character Creation return-pass (label contains "Return" or "return"):
///     speak "Character N" only (no prompt).
class HandsFreeAnnouncementPolicy {
  HandsFreeAnnouncementPolicy(this._tts);

  final TtsService _tts;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call when a new segment becomes active (i.e. the segment just started).
  Future<void> onSegmentStart(
    DrillSegment segment, {
    bool paused = false,
  }) async {
    if (paused) return;
    if (segment.type == DrillSegmentType.regroup) return;

    final label = segment.label ?? '';

    // Character Creation return-pass: speak "Character N" only.
    if (_isReturnPass(label)) {
      final charNum = _extractCharacterNumber(label);
      if (charNum != null) {
        await _tts.speak('Character $charNum');
      }
      return;
    }

    // Character Creation first-pass: speak "Character N: [prompt]".
    if (_isFirstPass(label)) {
      final charNum = _extractCharacterNumber(label);
      final prompt = segment.promptPayload;
      if (charNum != null && prompt != null) {
        await _tts.speak('Character $charNum: $prompt');
      } else if (charNum != null) {
        await _tts.speak('Character $charNum');
      }
      return;
    }

    // Regular segment with a prompt.
    if (segment.promptPayload != null) {
      await _tts.speak(segment.promptPayload!);
    }
  }

  /// Call every tick while a segment is running.
  /// [remaining] is the time left in the segment at the time of this tick.
  Future<void> onTick(
    DrillSegment segment,
    Duration remaining, {
    bool paused = false,
  }) async {
    if (paused) return;
    if (segment.type == DrillSegmentType.regroup) return;
    // No timer announcements for segments at or under 30 seconds.
    if (segment.duration.inSeconds <= 30) return;

    final secs = remaining.inSeconds;
    if (secs == 30) {
      await _tts.speak('30 seconds');
    } else if (secs == 10) {
      await _tts.speak('10 seconds');
    } else if (secs == 0) {
      await _tts.speak('time');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isReturnPass(String label) {
    final lower = label.toLowerCase();
    return lower.contains('return');
  }

  bool _isFirstPass(String label) {
    final lower = label.toLowerCase();
    return lower.contains('pass 1') ||
        lower.contains('first') ||
        RegExp(r'character \d+$').hasMatch(lower);
  }

  int? _extractCharacterNumber(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
