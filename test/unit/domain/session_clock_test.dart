// ABOUTME: Unit tests for SessionClock, the pausable wall-clock stopwatch behind drill timing.
// ABOUTME: Drives time with an injected now() so every case is deterministic.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/session_clock.dart';

void main() {
  late DateTime now;
  late SessionClock clock;

  void advance(int ms) => now = now.add(Duration(milliseconds: ms));

  setUp(() {
    now = DateTime(2026, 11, 24, 12);
    clock = SessionClock(now: () => now);
  });

  test('starts at zero and is not running', () {
    expect(clock.elapsed, Duration.zero);
    expect(clock.isRunning, isFalse);
  });

  test('measures real time while running, however often it is read', () {
    clock.start();
    advance(3700);
    expect(clock.elapsed, const Duration(milliseconds: 3700));
  });

  test('excludes paused time and keeps partial seconds across pause', () {
    clock.start();
    advance(1500);
    clock.pause();
    advance(60000);
    expect(clock.elapsed, const Duration(milliseconds: 1500));
    clock.start();
    advance(500);
    expect(clock.elapsed, const Duration(seconds: 2));
  });

  test('start while running and pause while paused are no-ops', () {
    clock.start();
    advance(1000);
    clock.start();
    advance(1000);
    clock
      ..pause()
      ..pause();
    expect(clock.elapsed, const Duration(seconds: 2));
  });

  test('reset clears elapsed time and stops the clock', () {
    clock.start();
    advance(5000);
    clock.reset();
    advance(5000);
    expect(clock.elapsed, Duration.zero);
    expect(clock.isRunning, isFalse);
  });
}
