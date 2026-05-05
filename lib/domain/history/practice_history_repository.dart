// ABOUTME: Repository interface for storing and retrieving practice session history.
// ABOUTME: Sessions are logged silently when a drill runs for at least 30 seconds.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

abstract interface class PracticeHistoryRepository {
  Future<void> addSession(PracticeSession session);

  /// Returns all sessions, newest-first.
  Future<List<PracticeSession>> getSessions();

  /// Returns the [limit] most recent sessions, newest-first.
  Future<List<PracticeSession>> getRecentSessions({int limit = 20});

  /// Returns all sessions for a specific drill, newest-first.
  Future<List<PracticeSession>> getSessionsByDrill(DrillId drillId);

  Future<void> clearAll();
}
