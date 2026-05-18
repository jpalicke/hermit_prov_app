// ABOUTME: Drift database definition with all local storage tables.
// ABOUTME: Manages custom prompts, drill settings, practice sessions, and journal entries.

import 'package:drift/drift.dart';

part 'app_database.g.dart';

// ── Table definitions ──────────────────────────────────────────────────────

/// Stores user-created custom prompts.
@DataClassName('CustomPromptData')
class CustomPrompts extends Table {
  TextColumn get id => text()();
  TextColumn get promptText => text()();
  TextColumn get category => text()(); // PromptCategory.name
  IntColumn get createdAtMs => integer()(); // DateTime.millisecondsSinceEpoch
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores per-drill settings as JSON blobs.
class DrillSettingsTable extends Table {
  TextColumn get drillId => text()(); // DrillId.name
  TextColumn get settingsJson => text()(); // JSON blob

  @override
  Set<Column> get primaryKey => {drillId};
}

/// Stores logged practice sessions.
@DataClassName('PracticeSessionData')
class PracticeSessions extends Table {
  TextColumn get id => text()();
  TextColumn get drillId => text()();
  IntColumn get startedAtMs => integer()(); // DateTime.millisecondsSinceEpoch
  IntColumn get durationSeconds => integer()();
  IntColumn get loggedAtMs => integer()(); // DateTime.millisecondsSinceEpoch

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores user journal entries with optional drill tags.
@DataClassName('JournalEntryData')
class JournalEntries extends Table {
  TextColumn get id => text()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  TextColumn get drillTag => text().nullable()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ───────────────────────────────────────────────────────────────

@DriftDatabase(
    tables: [CustomPrompts, DrillSettingsTable, PracticeSessions, JournalEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
