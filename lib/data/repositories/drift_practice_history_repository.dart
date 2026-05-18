// ABOUTME: Drift-backed implementation of PracticeHistoryRepository for on-device persistence.
// ABOUTME: Practice sessions are stored in SQLite and returned newest-first by loggedAt.

import 'package:drift/drift.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

class DriftPracticeHistoryRepository implements PracticeHistoryRepository {
  DriftPracticeHistoryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> addSession(PracticeSession session) async {
    await _db.into(_db.practiceSessions).insert(
          PracticeSessionsCompanion(
            id: Value(session.id),
            drillId: Value(session.drillId.name),
            startedAtMs: Value(session.startedAt.millisecondsSinceEpoch),
            durationSeconds: Value(session.duration.inSeconds),
            loggedAtMs: Value(session.loggedAt.millisecondsSinceEpoch),
          ),
        );
  }

  @override
  Future<List<PracticeSession>> getSessions() async {
    final rows = await (_db.select(_db.practiceSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAtMs)]))
        .get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<List<PracticeSession>> getRecentSessions({int limit = 20}) async {
    final rows = await (_db.select(_db.practiceSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAtMs)])
          ..limit(limit))
        .get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<List<PracticeSession>> getSessionsByDrill(DrillId drillId) async {
    final rows = await (_db.select(_db.practiceSessions)
          ..where((t) => t.drillId.equals(drillId.name))
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAtMs)]))
        .get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.practiceSessions).go();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  PracticeSession _rowToDomain(PracticeSessionData row) => PracticeSession(
        id: row.id,
        drillId: DrillId.values.byName(row.drillId),
        startedAt: DateTime.fromMillisecondsSinceEpoch(row.startedAtMs),
        duration: Duration(seconds: row.durationSeconds),
        loggedAt: DateTime.fromMillisecondsSinceEpoch(row.loggedAtMs),
      );
}
