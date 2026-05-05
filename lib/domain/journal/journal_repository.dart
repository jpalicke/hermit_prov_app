// ABOUTME: Repository interface for CRUD operations on practice journal entries.
// ABOUTME: Entries are stored locally and returned in newest-first order.

import 'package:hermit_prov_app/domain/journal/journal_entry.dart';

abstract interface class JournalRepository {
  Future<List<JournalEntry>> getEntries();
  Future<void> addEntry(JournalEntry entry);
  Future<void> updateEntry(JournalEntry entry);
  Future<void> deleteEntry(String id);
  Future<void> clearAll();
}
