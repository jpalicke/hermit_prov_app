// ABOUTME: Immutable snapshot of the DrillSessionController state at any point in time.
// ABOUTME: Describes status, current segment, time remaining, and session progress.

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';

/// Possible lifecycle phases of a drill session.
enum DrillSessionStatus {
  /// Not yet started.
  idle,

  /// Actively counting down.
  running,

  /// Paused mid-segment.
  paused,

  /// All segments completed (finite drills only).
  completed,

  /// The user stopped the session before it finished.
  stopped,
}

/// Immutable snapshot of drill session state.
class DrillSessionState {
  const DrillSessionState({
    required this.status,
    required this.segments,
    required this.currentSegmentIndex,
    required this.segmentElapsed,
    required this.sessionElapsed,
    required this.loops,
  });

  /// Constructs the initial idle state for a given segment list.
  factory DrillSessionState.initial(List<DrillSegment> segments) {
    return DrillSessionState(
      status: DrillSessionStatus.idle,
      segments: List.unmodifiable(segments),
      currentSegmentIndex: 0,
      segmentElapsed: Duration.zero,
      sessionElapsed: Duration.zero,
      loops: 0,
    );
  }

  final DrillSessionStatus status;

  /// Full ordered list of segments for the current loop.
  final List<DrillSegment> segments;

  /// Index into [segments] of the active segment.
  final int currentSegmentIndex;

  /// How much time has passed in the current segment.
  final Duration segmentElapsed;

  /// Total time elapsed since the session started (paused time excluded).
  final Duration sessionElapsed;

  /// How many complete loops have been run (relevant for looping drills).
  final int loops;

  // ── Derived properties ────────────────────────────────────────────────────

  bool get isIdle => status == DrillSessionStatus.idle;
  bool get isRunning => status == DrillSessionStatus.running;
  bool get isPaused => status == DrillSessionStatus.paused;
  bool get isCompleted => status == DrillSessionStatus.completed;
  bool get isStopped => status == DrillSessionStatus.stopped;
  bool get isActive => isRunning || isPaused;

  /// The currently active [DrillSegment], or null if the list is empty.
  DrillSegment? get currentSegment =>
      segments.isNotEmpty ? segments[currentSegmentIndex] : null;

  /// How much time is left in the current segment.
  Duration get segmentRemaining {
    final seg = currentSegment;
    if (seg == null) return Duration.zero;
    final remaining = seg.duration - segmentElapsed;
    return remaining < Duration.zero ? Duration.zero : remaining;
  }

  /// Circular progress value for the current segment, in the range 0.0–1.0.
  /// 0.0 means just started; 1.0 means segment is complete.
  double get segmentProgress {
    final seg = currentSegment;
    if (seg == null || seg.duration == Duration.zero) return 0.0;
    final raw = segmentElapsed.inMicroseconds / seg.duration.inMicroseconds;
    return raw.clamp(0.0, 1.0);
  }

  DrillSessionState copyWith({
    DrillSessionStatus? status,
    List<DrillSegment>? segments,
    int? currentSegmentIndex,
    Duration? segmentElapsed,
    Duration? sessionElapsed,
    int? loops,
  }) {
    return DrillSessionState(
      status: status ?? this.status,
      segments: segments != null
          ? List.unmodifiable(segments)
          : this.segments,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      segmentElapsed: segmentElapsed ?? this.segmentElapsed,
      sessionElapsed: sessionElapsed ?? this.sessionElapsed,
      loops: loops ?? this.loops,
    );
  }

  @override
  String toString() => 'DrillSessionState('
      'status: $status, '
      'segment: $currentSegmentIndex/${segments.length}, '
      'remaining: $segmentRemaining, '
      'sessionElapsed: $sessionElapsed)';
}
