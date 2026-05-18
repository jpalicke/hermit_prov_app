// ABOUTME: Unit tests for PracticeStats.compute() — totals, streaks, and per-drill breakdowns.
// ABOUTME: All tests use fixed dates to avoid clock-dependent failures.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';
import 'package:hermit_prov_app/domain/history/practice_stats.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

PracticeSession _session({
  required String id,
  required DrillId drillId,
  required DateTime loggedAt,
  Duration duration = const Duration(minutes: 5),
}) {
  return PracticeSession(
    id: id,
    drillId: drillId,
    startedAt: loggedAt.subtract(duration),
    duration: duration,
    loggedAt: loggedAt,
  );
}

DateTime _day(int year, int month, int day) =>
    DateTime(year, month, day, 12, 0);

/// Returns a DateTime [offset] days before today at noon.
DateTime _daysAgo(DateTime today, int offset) => DateTime(
      today.year,
      today.month,
      today.day - offset,
      12,
      0,
    );

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('PracticeStats.compute', () {
    test('returns empty stats for empty session list', () {
      final stats = PracticeStats.compute([]);
      expect(stats.totalTime, Duration.zero);
      expect(stats.sessionsCompleted, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.timeByDrill, isEmpty);
      expect(stats.sessionsByDrill, isEmpty);
    });

    test('sums total practice time across all sessions', () {
      final sessions = [
        _session(
          id: '1',
          drillId: DrillId.catClock,
          loggedAt: _day(2025, 1, 1),
          duration: const Duration(minutes: 3),
        ),
        _session(
          id: '2',
          drillId: DrillId.atoC,
          loggedAt: _day(2025, 1, 2),
          duration: const Duration(minutes: 7),
        ),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.totalTime, const Duration(minutes: 10));
    });

    test('counts sessions completed', () {
      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 1)),
        _session(id: '2', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 2)),
        _session(id: '3', drillId: DrillId.atoC, loggedAt: _day(2025, 1, 3)),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.sessionsCompleted, 3);
    });

    test('computes current streak for consecutive days ending today', () {
      final today = DateTime.now();
      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: _daysAgo(today, 0)),
        _session(id: '2', drillId: DrillId.catClock, loggedAt: _daysAgo(today, 1)),
        _session(id: '3', drillId: DrillId.catClock, loggedAt: _daysAgo(today, 2)),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.currentStreak, 3);
    });

    test('current streak is 1 when only yesterday has a session', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final d = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        12,
        0,
      );
      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: d),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.currentStreak, 1);
    });

    test('current streak is 0 when last session was 2 days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final d = DateTime(
        twoDaysAgo.year,
        twoDaysAgo.month,
        twoDaysAgo.day,
        12,
        0,
      );
      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: d),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.currentStreak, 0);
    });

    test('current streak breaks on gap', () {
      final today = DateTime.now();
      // Today and yesterday: streak of 2, but 3 days ago has a gap.
      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: _daysAgo(today, 0)),
        _session(id: '2', drillId: DrillId.catClock, loggedAt: _daysAgo(today, 1)),
        // Gap: no session on day 2
        _session(id: '3', drillId: DrillId.catClock, loggedAt: _daysAgo(today, 3)),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.currentStreak, 2);
    });

    test('computes longest streak across history', () {
      // Build a history with a 4-day run and a later 2-day run.
      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 1)),
        _session(id: '2', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 2)),
        _session(id: '3', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 3)),
        _session(id: '4', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 4)),
        // Gap
        _session(id: '5', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 10)),
        _session(id: '6', drillId: DrillId.catClock, loggedAt: _day(2025, 1, 11)),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.longestStreak, 4);
    });

    test('breaks down time and session count by drill', () {
      final sessions = [
        _session(
          id: '1',
          drillId: DrillId.catClock,
          loggedAt: _day(2025, 1, 1),
          duration: const Duration(minutes: 4),
        ),
        _session(
          id: '2',
          drillId: DrillId.catClock,
          loggedAt: _day(2025, 1, 2),
          duration: const Duration(minutes: 6),
        ),
        _session(
          id: '3',
          drillId: DrillId.atoC,
          loggedAt: _day(2025, 1, 3),
          duration: const Duration(minutes: 2),
        ),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.sessionsByDrill[DrillId.catClock], 2);
      expect(stats.timeByDrill[DrillId.catClock], const Duration(minutes: 10));
      expect(stats.sessionsByDrill[DrillId.atoC], 1);
      expect(stats.timeByDrill[DrillId.atoC], const Duration(minutes: 2));
      expect(stats.sessionsByDrill[DrillId.twoCharacterScenes], isNull);
    });

    test('multiple sessions on same day count as one practice day for streaks', () {
      final today = DateTime.now();
      final todayNoon = DateTime(today.year, today.month, today.day, 12, 0);
      final todayEvening = DateTime(today.year, today.month, today.day, 18, 0);

      final sessions = [
        _session(id: '1', drillId: DrillId.catClock, loggedAt: todayNoon),
        _session(id: '2', drillId: DrillId.catClock, loggedAt: todayEvening),
      ];
      final stats = PracticeStats.compute(sessions);
      expect(stats.currentStreak, 1);
    });
  });
}
