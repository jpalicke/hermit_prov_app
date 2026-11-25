// ABOUTME: Repository tests for DriftPracticeHistoryRepository using an in-memory Drift database.
// ABOUTME: Verifies sessions round-trip through SQLite, sort by loggedAt, limit, filter and clear.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/data/repositories/drift_practice_history_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

void main() {
  late AppDatabase db;
  late DriftPracticeHistoryRepository repo;

  PracticeSession session(String id, DrillId drill, int day) => PracticeSession(
        id: id,
        drillId: drill,
        startedAt: DateTime(2026, 5, day, 8),
        duration: Duration(seconds: 60 + day),
        loggedAt: DateTime(2026, 5, day, 8, 1),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftPracticeHistoryRepository(db);
  });

  tearDown(() => db.close());

  test('stored sessions come back with every field intact, newest first',
      () async {
    await repo.addSession(session('1', DrillId.atoC, 1));
    await repo.addSession(session('3', DrillId.fiveLineGame, 3));
    await repo.addSession(session('2', DrillId.atoC, 2));

    final sessions = await repo.getSessions();

    expect(sessions.map((s) => s.id), ['3', '2', '1']);
    final s = sessions.first;
    expect(s.drillId, DrillId.fiveLineGame);
    expect(s.startedAt, DateTime(2026, 5, 3, 8));
    expect(s.duration, const Duration(seconds: 63));
    expect(s.loggedAt, DateTime(2026, 5, 3, 8, 1));
  });

  test('getRecentSessions returns at most limit sessions, newest first',
      () async {
    for (var day = 1; day <= 4; day++) {
      await repo.addSession(session('$day', DrillId.atoC, day));
    }

    final recent = await repo.getRecentSessions(limit: 2);

    expect(recent.map((s) => s.id), ['4', '3']);
  });

  test('getSessionsByDrill filters by drill; clearAll removes everything',
      () async {
    await repo.addSession(session('1', DrillId.atoC, 1));
    await repo.addSession(session('2', DrillId.fiveLineGame, 2));

    expect(
      (await repo.getSessionsByDrill(DrillId.atoC)).map((s) => s.id),
      ['1'],
    );

    await repo.clearAll();
    expect(await repo.getSessions(), isEmpty);
  });
}
