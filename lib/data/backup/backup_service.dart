// ABOUTME: Abstract interface for building, exporting, importing, and merging app backups.
// ABOUTME: Implementations collect data from repositories and produce/consume JSON strings.

import 'package:hermit_prov_app/domain/backup/app_backup.dart';

/// Result returned by [BackupService.mergeIntoApp] describing what was applied.
class BackupMergeResult {
  const BackupMergeResult({
    required this.promptsAdded,
    required this.journalEntriesAdded,
    required this.settingsUpdated,
  });

  /// Number of custom prompts inserted (skipped if id already existed).
  final int promptsAdded;

  /// Number of journal entries inserted (skipped if id already existed).
  final int journalEntriesAdded;

  /// Number of settings/preference groups overwritten (0 or more).
  final int settingsUpdated;
}

abstract interface class BackupService {
  /// Collects all exportable data from repositories and returns a snapshot.
  Future<AppBackup> buildBackup();

  /// Serialises [backup] to a JSON string suitable for writing to a file.
  Future<String> exportToJson(AppBackup backup);

  /// Parses [json] and validates the schemaVersion.
  /// Throws [FormatException] if the JSON is malformed or schemaVersion != 1.
  Future<AppBackup> importFromJson(String json);

  /// Applies [backup] to the repositories.
  /// Custom prompts and journal entries are skipped when their id already exists.
  /// Drill settings and preferences are always overwritten (last-write-wins).
  Future<BackupMergeResult> mergeIntoApp(AppBackup backup);
}
