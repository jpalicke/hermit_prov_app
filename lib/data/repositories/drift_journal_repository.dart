// ABOUTME: Drift-backed implementation of JournalRepository for on-device persistence.
// ABOUTME: Journal entries are stored in SQLite and returned newest-first by createdAt.

import 'package:drift/drift.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/domain/journal/journal_repository.dart';

class DriftJournalRepository implements JournalRepository {
  DriftJournalRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<JournalEntry>> getEntries() async {
    final rows = await (_db.select(_db.journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<List<JournalEntry>> getEntriesByDrill(DrillId drillId) async {
    final rows = await (_db.select(_db.journalEntries)
          ..where((t) => t.drillTag.equals(drillId.name))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<void> addEntry(JournalEntry entry) async {
    await _db.into(_db.journalEntries).insert(
          JournalEntriesCompanion(
            id: Value(entry.id),
            createdAtMs: Value(entry.createdAt.millisecondsSinceEpoch),
            updatedAtMs: Value(entry.updatedAt.millisecondsSinceEpoch),
            drillTag: Value(entry.drillId?.name),
            body: Value(entry.body),
          ),
        );
  }

  @override
  Future<void> updateEntry(JournalEntry entry) async {
    await (_db.update(_db.journalEntries)
          ..where((t) => t.id.equals(entry.id)))
        .write(
      JournalEntriesCompanion(
        updatedAtMs: Value(entry.updatedAt.millisecondsSinceEpoch),
        drillTag: Value(entry.drillId?.name),
        body: Value(entry.body),
      ),
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    await (_db.delete(_db.journalEntries)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.journalEntries).go();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  JournalEntry _rowToDomain(JournalEntryData row) => JournalEntry(
        id: row.id,
        body: row.body,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs),
        drillId:
            row.drillTag == null ? null : DrillId.values.byName(row.drillTag!),
      );
}
