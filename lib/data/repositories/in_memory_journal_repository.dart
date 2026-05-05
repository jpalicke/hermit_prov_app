// ABOUTME: In-memory implementation of JournalRepository.
// ABOUTME: Stores entries in a map keyed by id; returns them newest-first.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/domain/journal/journal_repository.dart';

class InMemoryJournalRepository implements JournalRepository {
  final Map<String, JournalEntry> _entries = {};

  @override
  Future<List<JournalEntry>> getEntries() async {
    return _newestFirst(_entries.values.toList());
  }

  @override
  Future<List<JournalEntry>> getEntriesByDrill(DrillId drillId) async {
    return _newestFirst(
      _entries.values.where((e) => e.drillId == drillId).toList(),
    );
  }

  @override
  Future<void> addEntry(JournalEntry entry) async {
    _entries[entry.id] = entry;
  }

  @override
  Future<void> updateEntry(JournalEntry entry) async {
    _entries[entry.id] = entry;
  }

  @override
  Future<void> deleteEntry(String id) async => _entries.remove(id);

  @override
  Future<void> clearAll() async => _entries.clear();

  // ── helpers ────────────────────────────────────────────────────────────────

  List<JournalEntry> _newestFirst(List<JournalEntry> list) {
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
