// ABOUTME: Concrete BackupService that reads from and writes to all local repositories.
// ABOUTME: Serializes domain objects to JSON maps using field-level encoding matched to the existing Drift mapping pattern.

import 'dart:convert';

import 'package:hermit_prov_app/data/backup/backup_service.dart';
import 'package:hermit_prov_app/domain/backup/app_backup.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/domain/journal/journal_repository.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';

/// The only schema version this service can read or write.
const int _currentSchemaVersion = 1;

class LocalBackupService implements BackupService {
  LocalBackupService({
    required PromptRepository promptRepository,
    required JournalRepository journalRepository,
    required DrillSettingsRepository drillSettingsRepository,
    required AppPreferencesRepository appPreferencesRepository,
  })  : _prompts = promptRepository,
        _journal = journalRepository,
        _drillSettings = drillSettingsRepository,
        _prefs = appPreferencesRepository;

  final PromptRepository _prompts;
  final JournalRepository _journal;
  final DrillSettingsRepository _drillSettings;
  final AppPreferencesRepository _prefs;

  // ── BackupService interface ───────────────────────────────────────────────

  @override
  Future<AppBackup> buildBackup() async {
    final customPrompts = await _prompts.getCustomPrompts();
    final journalEntries = await _journal.getEntries();
    final prefs = await _prefs.getPreferences();

    final drillSettingsMap = <String, dynamic>{};
    for (final id in DrillId.values) {
      final settings = await _drillSettings.getSettings(id);
      drillSettingsMap[id.name] = settings.toJson();
    }

    return AppBackup(
      schemaVersion: _currentSchemaVersion,
      exportedAt: DateTime.now().toUtc(),
      customPrompts: customPrompts.map(_promptToJson).toList(),
      journalEntries: journalEntries.map(_entryToJson).toList(),
      drillSettings: drillSettingsMap,
      preferences: _prefsToJson(prefs),
    );
  }

  @override
  Future<String> exportToJson(AppBackup backup) async {
    return const JsonEncoder.withIndent('  ').convert(backup.toJson());
  }

  @override
  Future<AppBackup> importFromJson(String json) async {
    late Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Backup file is not valid JSON.');
    }

    final version = decoded['schemaVersion'];
    if (version != _currentSchemaVersion) {
      throw FormatException(
        'Unsupported backup schema version: $version. Expected $_currentSchemaVersion.',
      );
    }

    return AppBackup.fromJson(decoded);
  }

  @override
  Future<BackupMergeResult> mergeIntoApp(AppBackup backup) async {
    // Merge custom prompts -- skip any whose id already exists.
    final existingPrompts = await _prompts.getCustomPrompts();
    final existingPromptIds = {for (final p in existingPrompts) p.id};
    int promptsAdded = 0;
    for (final map in backup.customPrompts) {
      final prompt = _promptFromJson(map);
      if (!existingPromptIds.contains(prompt.id)) {
        await _prompts.addCustomPrompt(prompt);
        promptsAdded++;
      }
    }

    // Merge journal entries -- skip any whose id already exists.
    final existingEntries = await _journal.getEntries();
    final existingEntryIds = {for (final e in existingEntries) e.id};
    int journalEntriesAdded = 0;
    for (final map in backup.journalEntries) {
      final entry = _entryFromJson(map);
      if (!existingEntryIds.contains(entry.id)) {
        await _journal.addEntry(entry);
        journalEntriesAdded++;
      }
    }

    // Overwrite drill settings (last-write-wins).
    int settingsUpdated = 0;
    for (final rawEntry in backup.drillSettings.entries) {
      final drillId = DrillId.values.byName(rawEntry.key);
      final settings = DrillSettings.fromJson(
        drillId,
        (rawEntry.value as Map<String, dynamic>),
      );
      await _drillSettings.saveSettings(settings);
      settingsUpdated++;
    }

    // Overwrite preferences (last-write-wins). Count as 1 if present.
    if (backup.preferences.isNotEmpty) {
      final prefs = _prefsFromJson(backup.preferences);
      await _prefs.savePreferences(prefs);
      settingsUpdated++;
    }

    return BackupMergeResult(
      promptsAdded: promptsAdded,
      journalEntriesAdded: journalEntriesAdded,
      settingsUpdated: settingsUpdated,
    );
  }

  // ── Serialization helpers ─────────────────────────────────────────────────

  Map<String, dynamic> _promptToJson(CustomPrompt p) => {
        'id': p.id,
        'text': p.text,
        'category': p.category.name,
        'createdAt': p.createdAt.toUtc().toIso8601String(),
        'updatedAt': p.updatedAt.toUtc().toIso8601String(),
      };

  CustomPrompt _promptFromJson(Map<String, dynamic> json) {
    return CustomPrompt(
      id: json['id'] as String,
      text: json['text'] as String,
      category: PromptCategory.values.byName(json['category'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _entryToJson(JournalEntry e) => {
        'id': e.id,
        'body': e.body,
        'createdAt': e.createdAt.toUtc().toIso8601String(),
        'updatedAt': e.updatedAt.toUtc().toIso8601String(),
        'drillId': e.drillId?.name,
      };

  JournalEntry _entryFromJson(Map<String, dynamic> json) {
    final drillIdStr = json['drillId'] as String?;
    return JournalEntry(
      id: json['id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      drillId: drillIdStr == null ? null : DrillId.values.byName(drillIdStr),
    );
  }

  Map<String, dynamic> _prefsToJson(AppPreferences p) => {
        'themePreference': p.themePreference.name,
        'ttsSpeakingRate': p.ttsSpeakingRate,
      };

  AppPreferences _prefsFromJson(Map<String, dynamic> json) {
    return AppPreferences(
      themePreference: AppThemePreference.values
          .byName(json['themePreference'] as String),
      ttsSpeakingRate: (json['ttsSpeakingRate'] as num).toDouble(),
    );
  }
}
