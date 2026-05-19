// ABOUTME: Pure-Dart state machine for drill sessions — no Flutter dependencies.
// ABOUTME: Accepts manual tick steps so timer logic is fully testable without real time.

import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';

/// Controls the lifecycle of a single drill session.
///
/// The session is driven by [tick] calls, which advance elapsed time by a
/// fixed [tickDuration].  This design removes the dependency on `dart:async`
/// timers, making unit tests completely deterministic.
///
/// Usage:
///   1. Create a controller with the initial segment list.
///   2. Call [start] to begin.
///   3. Repeatedly call [tick] (e.g. once per second from a real Timer or
///      many times in a test) to advance time.
///   4. Call [pause] / [resume] as needed.
///   5. Call [stop] to end early or let the session complete naturally.
class DrillSessionController {
  DrillSessionController({
    required List<DrillSegment> segments,
    this.loops = false,
    this.tickDuration = const Duration(seconds: 1),
  })  : assert(segments.isNotEmpty, 'segments must not be empty'),
        _baseSegments = List.unmodifiable(segments),
        _state = DrillSessionState.initial(segments);

  /// The canonical segment list for one complete pass / loop.
  final List<DrillSegment> _baseSegments;

  /// Whether the session restarts from the beginning after the last segment.
  final bool loops;

  /// The time increment applied by each [tick] call.
  final Duration tickDuration;

  DrillSessionState _state;

  /// Current immutable snapshot of the session state.
  DrillSessionState get state => _state;

  // ── Commands ──────────────────────────────────────────────────────────────

  /// Transitions from [DrillSessionStatus.idle] to [DrillSessionStatus.running].
  void start() {
    if (!_state.isIdle) return;
    _state = _state.copyWith(status: DrillSessionStatus.running);
  }

  /// Pauses a running session.  No-op if not running.
  void pause() {
    if (!_state.isRunning) return;
    _state = _state.copyWith(status: DrillSessionStatus.paused);
  }

  /// Resumes a paused session.  No-op if not paused.
  void resume() {
    if (!_state.isPaused) return;
    _state = _state.copyWith(status: DrillSessionStatus.running);
  }

  /// Stops the session early.  Can be called from idle or any active status.
  void stop() {
    if (!_state.isIdle && !_state.isActive) return;
    _state = _state.copyWith(status: DrillSessionStatus.stopped);
  }

  /// Resets the session to idle with the original segment list and zero elapsed time.
  void reset() {
    _state = DrillSessionState.initial(_baseSegments);
  }

  /// Advances the session clock by [tickDuration].
  ///
  /// Only has effect when the session is [DrillSessionStatus.running].
  /// Handles segment completion, looping, and finite session end.
  void tick() {
    if (!_state.isRunning) return;

    final newSegmentElapsed = _state.segmentElapsed + tickDuration;
    final newSessionElapsed = _state.sessionElapsed + tickDuration;
    final currentSeg = _state.currentSegment!;

    if (newSegmentElapsed >= currentSeg.duration) {
      // Segment completed — try to advance.
      _handleSegmentComplete(newSessionElapsed);
    } else {
      _state = _state.copyWith(
        segmentElapsed: newSegmentElapsed,
        sessionElapsed: newSessionElapsed,
      );
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _handleSegmentComplete(Duration newSessionElapsed) {
    final nextIndex = _state.currentSegmentIndex + 1;

    if (nextIndex < _state.segments.length) {
      // Advance to next segment in the current loop.
      _state = _state.copyWith(
        currentSegmentIndex: nextIndex,
        segmentElapsed: Duration.zero,
        sessionElapsed: newSessionElapsed,
      );
    } else if (loops) {
      // All segments done — restart the loop.
      _state = DrillSessionState(
        status: DrillSessionStatus.running,
        segments: _baseSegments,
        currentSegmentIndex: 0,
        segmentElapsed: Duration.zero,
        sessionElapsed: newSessionElapsed,
        loops: _state.loops + 1,
      );
    } else {
      // Finite session — mark as completed.
      _state = _state.copyWith(
        status: DrillSessionStatus.completed,
        segmentElapsed: _state.currentSegment!.duration,
        sessionElapsed: newSessionElapsed,
      );
    }
  }
}
