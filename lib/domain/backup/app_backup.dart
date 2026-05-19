// ABOUTME: Value object representing a full app data backup as a serializable snapshot.
// ABOUTME: Covers custom prompts, journal entries, drill settings, and preferences (not practice history).

class AppBackup {
  const AppBackup({
    required this.schemaVersion,
    required this.exportedAt,
    required this.customPrompts,
    required this.journalEntries,
    required this.drillSettings,
    required this.preferences,
  });

  /// Version of the backup schema. Must be 1 for the current release.
  final int schemaVersion;

  /// UTC timestamp when this backup was created.
  final DateTime exportedAt;

  /// Raw JSON maps for each custom prompt.
  final List<Map<String, dynamic>> customPrompts;

  /// Raw JSON maps for each journal entry.
  final List<Map<String, dynamic>> journalEntries;

  /// Drill settings keyed by DrillId.name (e.g. "catClock").
  final Map<String, dynamic> drillSettings;

  /// App-wide preference fields (theme, TTS voice, TTS speaking rate).
  final Map<String, dynamic> preferences;

  factory AppBackup.fromJson(Map<String, dynamic> json) {
    return AppBackup(
      schemaVersion: json['schemaVersion'] as int,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      customPrompts: (json['customPrompts'] as List)
          .cast<Map<String, dynamic>>(),
      journalEntries: (json['journalEntries'] as List)
          .cast<Map<String, dynamic>>(),
      drillSettings:
          (json['drillSettings'] as Map<String, dynamic>),
      preferences: (json['preferences'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'customPrompts': customPrompts,
        'journalEntries': journalEntries,
        'drillSettings': drillSettings,
        'preferences': preferences,
      };
}
