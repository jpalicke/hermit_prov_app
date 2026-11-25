// ABOUTME: Pins the version 1 backup file format with a fixed fixture, in both directions.
// ABOUTME: Renaming a key would make old backups fail to restore or new ones unreadable.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/backup/local_backup_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';

const _prompt = {
  'id': 'p1',
  'text': 'A lighthouse keeper',
  'category': 'occupations',
  'createdAt': '2024-01-02T03:04:05.000Z',
  'updatedAt': '2024-01-03T03:04:05.000Z',
};
const _entry = {
  'id': 'j1',
  'body': 'Found the game early',
  'createdAt': '2024-02-02T03:04:05.000Z',
  'updatedAt': '2024-02-03T03:04:05.000Z',
  'drillId': 'atoC',
};
const _atocSettings = {
  'interval': 45000,
  'promptCategories': ['events'],
  'handsFreeModeEnabled': true,
};
const _prefs = {'themePreference': 'dark', 'ttsSpeakingRate': 1.5};

void main() {
  late AppServices services;
  late LocalBackupService backup;

  setUp(() {
    services = AppServices.withInMemory(child: const SizedBox());
    backup = LocalBackupService(
      promptRepository: services.promptRepository,
      journalRepository: services.journalRepository,
      drillSettingsRepository: services.drillSettingsRepository,
      appPreferencesRepository: services.appPreferencesRepository,
    );
  });

  test('a version 1 backup file restores every field and reports exact counts',
      () async {
    final file = jsonEncode({
      'schemaVersion': 1,
      'exportedAt': '2024-03-01T00:00:00.000Z',
      'customPrompts': [_prompt],
      'journalEntries': [_entry],
      'drillSettings': {'atoC': _atocSettings},
      'preferences': _prefs,
    });

    final result = await backup.mergeIntoApp(await backup.importFromJson(file));

    expect(result.promptsAdded, 1);
    expect(result.journalEntriesAdded, 1);
    expect(result.settingsUpdated, 2, reason: 'one drill + preferences');

    final prompt = (await services.promptRepository.getCustomPrompts()).single;
    expect(prompt.id, 'p1');
    expect(prompt.text, 'A lighthouse keeper');
    expect(prompt.category, PromptCategory.occupations);
    expect(prompt.createdAt, DateTime.utc(2024, 1, 2, 3, 4, 5));
    expect(prompt.updatedAt, DateTime.utc(2024, 1, 3, 3, 4, 5));

    final entry = (await services.journalRepository.getEntries()).single;
    expect(entry.id, 'j1');
    expect(entry.body, 'Found the game early');
    expect(entry.createdAt, DateTime.utc(2024, 2, 2, 3, 4, 5));
    expect(entry.updatedAt, DateTime.utc(2024, 2, 3, 3, 4, 5));
    expect(entry.drillId, DrillId.atoC);

    final atoc = await services.drillSettingsRepository
        .getSettings(DrillId.atoC) as AtoCSettings;
    expect(atoc.interval, const Duration(seconds: 45));
    expect(atoc.handsFreeModeEnabled, isTrue);

    final prefs = await services.appPreferencesRepository.getPreferences();
    expect(prefs.themePreference, AppThemePreference.dark);
    expect(prefs.ttsSpeakingRate, 1.5);
  });

  test('an export writes exactly the version 1 keys and values', () async {
    await services.promptRepository.addCustomPrompt(
      CustomPrompt(
        id: 'p1',
        text: 'A lighthouse keeper',
        category: PromptCategory.occupations,
        createdAt: DateTime.utc(2024, 1, 2, 3, 4, 5),
        updatedAt: DateTime.utc(2024, 1, 3, 3, 4, 5),
      ),
    );
    await services.journalRepository.addEntry(
      JournalEntry(
        id: 'j1',
        body: 'Found the game early',
        createdAt: DateTime.utc(2024, 2, 2, 3, 4, 5),
        updatedAt: DateTime.utc(2024, 2, 3, 3, 4, 5),
        drillId: DrillId.atoC,
      ),
    );
    await services.drillSettingsRepository.saveSettings(
      DrillSettings.fromJson(DrillId.atoC, _atocSettings),
    );
    await services.appPreferencesRepository.savePreferences(
      const AppPreferences(
        themePreference: AppThemePreference.dark,
        ttsSpeakingRate: 1.5,
      ),
    );

    final json = jsonDecode(
      await backup.exportToJson(await backup.buildBackup()),
    ) as Map<String, dynamic>;

    expect(json.keys, {
      'schemaVersion',
      'exportedAt',
      'customPrompts',
      'journalEntries',
      'drillSettings',
      'preferences',
    });
    expect(json['schemaVersion'], 1);
    expect(json['customPrompts'], [_prompt]);
    expect(json['journalEntries'], [_entry]);
    expect((json['drillSettings'] as Map)['atoC'], _atocSettings);
    expect(json['preferences'], _prefs);
  });

  test('a backup whose items already exist adds nothing but still applies '
      'settings', () async {
    final file = jsonEncode({
      'schemaVersion': 1,
      'exportedAt': '2024-03-01T00:00:00.000Z',
      'customPrompts': [_prompt],
      'journalEntries': [_entry],
      'drillSettings': {'atoC': _atocSettings, 'catClock': const CatClockSettings().toJson()},
      'preferences': <String, dynamic>{},
    });
    final parsed = await backup.importFromJson(file);
    await backup.mergeIntoApp(parsed);

    final again = await backup.mergeIntoApp(parsed);

    expect(again.promptsAdded, 0);
    expect(again.journalEntriesAdded, 0);
    expect(again.settingsUpdated, 2, reason: 'two drills, no preferences');
  });
}
