// ABOUTME: Unit tests for DrillSessionController — verifies timer, segment, looping, and pause logic.
// ABOUTME: Uses manual ticks (no real time) for deterministic testing.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

DrillSegment _seg(String id, {int seconds = 10}) => DrillSegment(
      id: id,
      type: DrillSegmentType.speaking,
      duration: Duration(seconds: seconds),
    );

/// Ticks the controller [count] times.
void _tick(DrillSessionController ctrl, int count) {
  for (var i = 0; i < count; i++) {
    ctrl.tick();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('DrillSessionController', () {
    // 1. Countdown decreases with ticks
    test('countdown decreases with ticks', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
        loops: true,
      );
      ctrl.start();

      _tick(ctrl, 3);

      expect(ctrl.state.segmentElapsed, const Duration(seconds: 3));
      expect(ctrl.state.segmentRemaining, const Duration(seconds: 7));
    });

    // 2. Segment completion advances to next segment
    test('segment completion advances to next segment', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 5), _seg('s1', seconds: 8)],
        loops: false,
      );
      ctrl.start();

      // Tick past the end of segment 0.
      _tick(ctrl, 5);

      expect(ctrl.state.currentSegmentIndex, 1);
      expect(ctrl.state.segmentElapsed, Duration.zero);
      expect(ctrl.state.status, DrillSessionStatus.running);
      expect(ctrl.state.currentSegment?.id, 's1');
    });

    // 3. Looping sequence restarts after final segment
    test('looping sequence restarts after final segment', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 3), _seg('s1', seconds: 3)],
        loops: true,
      );
      ctrl.start();

      // Tick through both segments (6 ticks).
      _tick(ctrl, 6);

      expect(ctrl.state.loops, 1);
      expect(ctrl.state.currentSegmentIndex, 0);
      expect(ctrl.state.status, DrillSessionStatus.running);
    });

    // 4. Finite sequence completes after final segment
    test('finite sequence completes after final segment', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 3), _seg('s1', seconds: 3)],
        loops: false,
      );
      ctrl.start();

      _tick(ctrl, 6);

      expect(ctrl.state.status, DrillSessionStatus.completed);
      expect(ctrl.state.loops, 0);
    });

    // 5. Pause freezes time and segment changes
    test('pause freezes time and segment changes', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
        loops: true,
      );
      ctrl.start();
      _tick(ctrl, 4);
      ctrl.pause();

      final frozenElapsed = ctrl.state.segmentElapsed;
      _tick(ctrl, 3); // These ticks should be ignored while paused.

      expect(ctrl.state.segmentElapsed, frozenElapsed);
      expect(ctrl.state.status, DrillSessionStatus.paused);
    });

    // 6. Resume continues correctly after pause
    test('resume continues from where it paused', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
        loops: true,
      );
      ctrl.start();
      _tick(ctrl, 4);
      ctrl.pause();
      ctrl.resume();
      _tick(ctrl, 2);

      expect(ctrl.state.segmentElapsed, const Duration(seconds: 6));
      expect(ctrl.state.status, DrillSessionStatus.running);
    });

    // 7. Progress calculation is correct
    test('progress calculation is correct', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
        loops: true,
      );
      ctrl.start();
      _tick(ctrl, 5);

      // 5 seconds elapsed out of 10 → 0.5
      expect(ctrl.state.segmentProgress, closeTo(0.5, 0.001));
    });

    // Extras: stop and idle state
    test('stop ends the session early', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
        loops: true,
      );
      ctrl.start();
      _tick(ctrl, 3);
      ctrl.stop();

      expect(ctrl.state.status, DrillSessionStatus.stopped);
      // Ticks after stop should be ignored.
      _tick(ctrl, 5);
      expect(ctrl.state.segmentElapsed, const Duration(seconds: 3));
    });

    test('start is a no-op if not idle', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
        loops: true,
      );
      ctrl.start();
      _tick(ctrl, 2);
      ctrl.start(); // Should be ignored.

      expect(ctrl.state.segmentElapsed, const Duration(seconds: 2));
    });

    test('session elapsed increases across segment boundaries', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 3), _seg('s1', seconds: 3)],
        loops: false,
      );
      ctrl.start();
      _tick(ctrl, 5);

      expect(ctrl.state.sessionElapsed, const Duration(seconds: 5));
    });

    test('initial state is idle', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 5)],
      );
      expect(ctrl.state.status, DrillSessionStatus.idle);
      expect(ctrl.state.segmentProgress, 0.0);
      expect(ctrl.state.segmentRemaining, const Duration(seconds: 5));
    });

    test('stop from idle transitions to stopped', () {
      final ctrl = DrillSessionController(
        segments: [_seg('s0', seconds: 10)],
      );
      // Session never started — stop should still transition to stopped.
      ctrl.stop();

      expect(ctrl.state.status, DrillSessionStatus.stopped);
    });
  });
}
