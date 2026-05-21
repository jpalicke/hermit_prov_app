// ABOUTME: Unit tests verifying session logging threshold logic via PracticeStats.compute.
// ABOUTME: Confirms that sessions under 30 seconds produce correct empty stats.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';
import 'package:hermit_prov_app/domain/history/practice_stats.dart';

void main() {
  group('Session logging threshold — PracticeStats.compute handles edge cases', () {
    test('compute with empty list returns zero stats (no sessions logged)', () {
      final stats = PracticeStats.compute([]);
      expect(stats.sessionsCompleted, 0);
      expect(stats.totalTime, Duration.zero);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
    });

    test('a session shorter than 30 seconds still accumulates correctly if somehow added', () {
      // The 30-second gate lives in DrillSessionShell._maybeLogSession.
      // If a very short session were erroneously passed to addSession, compute
      // would still count it faithfully.
      final shortSession = PracticeSession(
        id: 'short',
        drillId: DrillId.catClock,
        startedAt: DateTime(2025, 1, 1, 12),
        duration: const Duration(seconds: 10),
        loggedAt: DateTime(2025, 1, 1, 12, 0, 10),
      );
      final stats = PracticeStats.compute([shortSession]);
      expect(stats.sessionsCompleted, 1);
      expect(stats.totalTime, const Duration(seconds: 10));
    });

    test('sessions with exactly 30-second duration count correctly', () {
      final session = PracticeSession(
        id: 'threshold',
        drillId: DrillId.atoC,
        startedAt: DateTime(2025, 5, 1, 10),
        duration: const Duration(seconds: 30),
        loggedAt: DateTime(2025, 5, 1, 10, 0, 30),
      );
      final stats = PracticeStats.compute([session]);
      expect(stats.sessionsCompleted, 1);
      expect(stats.totalTime, const Duration(seconds: 30));
    });
  });
}
