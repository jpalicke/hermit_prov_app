// ABOUTME: Repository tests for DriftJournalRepository using an in-memory Drift database.
// ABOUTME: Verifies entries round-trip through SQLite, sort newest-first, filter, update and delete.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/data/repositories/drift_journal_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';

void main() {
  late AppDatabase db;
  late DriftJournalRepository repo;

  final older = JournalEntry(
    id: 'a',
    body: 'Worked on object work',
    createdAt: DateTime(2026, 3, 1, 9),
    updatedAt: DateTime(2026, 3, 1, 10),
    drillId: DrillId.catClock,
  );
  final newer = JournalEntry(
    id: 'b',
    body: 'Untagged thoughts',
    createdAt: DateTime(2026, 3, 2, 9),
    updatedAt: DateTime(2026, 3, 2, 9),
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftJournalRepository(db);
  });

  tearDown(() => db.close());

  test('stored entries come back with every field intact, newest first',
      () async {
    await repo.addEntry(older);
    await repo.addEntry(newer);

    final entries = await repo.getEntries();

    expect(entries.map((e) => e.id), ['b', 'a']);
    final a = entries.last;
    expect(a.body, older.body);
    expect(a.createdAt, older.createdAt);
    expect(a.updatedAt, older.updatedAt);
    expect(a.drillId, DrillId.catClock);
    expect(entries.first.drillId, isNull);
  });

  test('getEntriesByDrill returns only entries tagged with that drill',
      () async {
    await repo.addEntry(older);
    await repo.addEntry(newer);

    final tagged = await repo.getEntriesByDrill(DrillId.catClock);

    expect(tagged.map((e) => e.id), ['a']);
  });

  test('updateEntry changes body, tag and updatedAt but not createdAt',
      () async {
    await repo.addEntry(older);
    await repo.updateEntry(
      older.copyWith(
        body: 'Rewritten',
        drillId: null,
        updatedAt: DateTime(2026, 4),
        createdAt: DateTime(2030),
      ),
    );

    final entry = (await repo.getEntries()).single;
    expect(entry.body, 'Rewritten');
    expect(entry.drillId, isNull);
    expect(entry.updatedAt, DateTime(2026, 4));
    expect(entry.createdAt, older.createdAt);
  });

  test('deleteEntry removes only that entry; clearAll removes the rest',
      () async {
    await repo.addEntry(older);
    await repo.addEntry(newer);

    await repo.deleteEntry('a');
    expect((await repo.getEntries()).map((e) => e.id), ['b']);

    await repo.clearAll();
    expect(await repo.getEntries(), isEmpty);
  });
}
