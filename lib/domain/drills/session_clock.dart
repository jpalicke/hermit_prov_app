// ABOUTME: Pausable stopwatch that measures a drill session's running time from the wall clock.
// ABOUTME: Reads time from package:clock so tests (and fake_async) can control it.

import 'package:clock/clock.dart';

/// Measures how long a session has been running, excluding paused time.
///
/// Unlike counting timer callbacks, this reads real elapsed time, so late
/// callbacks and pause/resume never make the drill clock drift.
class SessionClock {
  SessionClock({DateTime Function()? now}) : _now = now ?? clock.now;

  final DateTime Function() _now;

  Duration _accumulated = Duration.zero;
  DateTime? _runningSince;

  bool get isRunning => _runningSince != null;

  /// Total running time so far, not counting time spent paused.
  Duration get elapsed {
    final since = _runningSince;
    if (since == null) return _accumulated;
    return _accumulated + _now().difference(since);
  }

  /// Starts or resumes measuring. No-op if already running.
  void start() {
    _runningSince ??= _now();
  }

  /// Stops measuring and keeps the time so far. No-op if not running.
  void pause() {
    final since = _runningSince;
    if (since == null) return;
    _accumulated += _now().difference(since);
    _runningSince = null;
  }

  /// Stops measuring and clears the elapsed time.
  void reset() {
    _accumulated = Duration.zero;
    _runningSince = null;
  }
}
