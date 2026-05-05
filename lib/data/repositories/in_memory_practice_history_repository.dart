// ABOUTME: In-memory implementation of PracticeHistoryRepository.
// ABOUTME: Stores sessions in a list; returns them newest-first.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

class InMemoryPracticeHistoryRepository implements PracticeHistoryRepository {
  final List<PracticeSession> _sessions = [];

  @override
  Future<void> addSession(PracticeSession session) async {
    _sessions.add(session);
  }

  @override
  Future<List<PracticeSession>> getSessions() async {
    return _newestFirst(_sessions);
  }

  @override
  Future<List<PracticeSession>> getRecentSessions({int limit = 20}) async {
    return _newestFirst(_sessions).take(limit).toList();
  }

  @override
  Future<List<PracticeSession>> getSessionsByDrill(DrillId drillId) async {
    return _newestFirst(
      _sessions.where((s) => s.drillId == drillId).toList(),
    );
  }

  @override
  Future<void> clearAll() async => _sessions.clear();

  // ── helpers ────────────────────────────────────────────────────────────────

  List<PracticeSession> _newestFirst(List<PracticeSession> list) {
    final sorted = List<PracticeSession>.from(list)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return sorted;
  }
}
