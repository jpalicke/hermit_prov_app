// ABOUTME: Pure-Dart domain class for computing aggregate practice statistics.
// ABOUTME: Call PracticeStats.compute(sessions) to derive totals, streaks, and per-drill breakdowns.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

class PracticeStats {
  const PracticeStats({
    required this.totalTime,
    required this.sessionsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.timeByDrill,
    required this.sessionsByDrill,
  });

  final Duration totalTime;
  final int sessionsCompleted;

  /// Consecutive calendar days of practice ending on today or yesterday.
  final int currentStreak;

  /// The longest consecutive-day practice run in all history.
  final int longestStreak;

  final Map<DrillId, Duration> timeByDrill;
  final Map<DrillId, int> sessionsByDrill;

  /// Returns empty stats when [sessions] is empty.
  static PracticeStats empty() {
    return const PracticeStats(
      totalTime: Duration.zero,
      sessionsCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      timeByDrill: {},
      sessionsByDrill: {},
    );
  }

  /// Computes aggregate stats from a list of sessions.
  ///
  /// Session ordering does not matter — all calculations sort internally.
  /// Day attribution uses [PracticeSession.loggedAt] in local time.
  static PracticeStats compute(List<PracticeSession> sessions) {
    if (sessions.isEmpty) return empty();

    Duration totalTime = Duration.zero;
    final Map<DrillId, Duration> timeByDrill = {};
    final Map<DrillId, int> sessionsByDrill = {};

    for (final s in sessions) {
      totalTime += s.duration;
      timeByDrill[s.drillId] =
          (timeByDrill[s.drillId] ?? Duration.zero) + s.duration;
      sessionsByDrill[s.drillId] = (sessionsByDrill[s.drillId] ?? 0) + 1;
    }

    final practiceDays = _practiceDays(sessions);
    final currentStreak = _computeCurrentStreak(practiceDays);
    final longestStreak = _computeLongestStreak(practiceDays);

    return PracticeStats(
      totalTime: totalTime,
      sessionsCompleted: sessions.length,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      timeByDrill: Map.unmodifiable(timeByDrill),
      sessionsByDrill: Map.unmodifiable(sessionsByDrill),
    );
  }

  // ── Internal helpers ────────────────────────────────────────────────────────

  /// Returns a sorted list of unique calendar days (local time) that have sessions.
  static List<DateTime> _practiceDays(List<PracticeSession> sessions) {
    final Set<String> seen = {};
    final List<DateTime> days = [];
    for (final s in sessions) {
      final d = s.loggedAt.toLocal();
      final key = '${d.year}-${d.month}-${d.day}';
      if (seen.add(key)) {
        days.add(DateTime(d.year, d.month, d.day));
      }
    }
    days.sort();
    return days;
  }

  /// Computes the current streak: consecutive days ending on today or yesterday.
  static int _computeCurrentStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Streak anchor: must end on today or yesterday.
    final last = sortedDays.last;
    if (last != today && last != yesterday) return 0;

    int streak = 1;
    for (int i = sortedDays.length - 2; i >= 0; i--) {
      final expected = sortedDays[i + 1].subtract(const Duration(days: 1));
      if (sortedDays[i] == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Computes the longest consecutive-day streak across all history.
  static int _computeLongestStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sortedDays.length; i++) {
      final expected = sortedDays[i - 1].add(const Duration(days: 1));
      if (sortedDays[i] == expected) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  /// Strips time from a DateTime, returning midnight local.
  static DateTime _dateOnly(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
