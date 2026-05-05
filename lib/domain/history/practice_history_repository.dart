// ABOUTME: Repository interface for storing and retrieving practice session history.
// ABOUTME: Sessions are logged silently when a drill runs for at least 30 seconds.

import 'package:hermit_prov_app/domain/history/practice_session.dart';

abstract interface class PracticeHistoryRepository {
  Future<void> addSession(PracticeSession session);
  Future<List<PracticeSession>> getSessions();
  Future<void> clearAll();
}
