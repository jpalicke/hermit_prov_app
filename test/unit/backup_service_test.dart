// ABOUTME: Unit tests for LocalBackupService covering build, round-trip, merge, and validation.
// ABOUTME: Uses in-memory repositories so no real storage is touched.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/backup/local_backup_service.dart';
import 'package:hermit_prov_app/domain/backup/app_backup.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

LocalBackupService _makeService(AppServices services) {
  return LocalBackupService(
    promptRepository: services.promptRepository,
    journalRepository: services.journalRepository,
    drillSettingsRepository: services.drillSettingsRepository,
    appPreferencesRepository: services.appPreferencesRepository,
  );
}

void main() {
  late AppServices services;
  late LocalBackupService backupService;

  setUp(() {
    services = AppServices.withInMemory(child: const SizedBox());
    backupService = _makeService(services);
  });

  group('buildBackup()', () {
    test('returns AppBackup with schemaVersion 1', () async {
      final backup = await backupService.buildBackup();
      expect(backup.schemaVersion, equals(1));
    });

    test('includes custom prompts added to the repo', () async {
      final now = DateTime(2024, 6);
      final prompt = CustomPrompt(
        id: 'prompt-abc',
        text: 'What if a dentist became a detective?',
        category: PromptCategory.objects,
        createdAt: now,
        updatedAt: now,
      );
      await services.promptRepository.addCustomPrompt(prompt);

      final backup = await backupService.buildBackup();
      expect(backup.customPrompts, hasLength(1));
      expect(backup.customPrompts.first['id'], equals('prompt-abc'));
    });

    test('includes journal entries added to the repo', () async {
      final now = DateTime(2024, 6, 2);
      await services.journalRepository.addEntry(
        JournalEntry(
          id: 'entry-xyz',
          body: 'Great practice session today.',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final backup = await backupService.buildBackup();
      expect(backup.journalEntries, hasLength(1));
      expect(backup.journalEntries.first['id'], equals('entry-xyz'));
    });

    test('drillSettings map contains all drill ids', () async {
      final backup = await backupService.buildBackup();
      expect(backup.drillSettings.keys,
          containsAll(['catClock', 'characterCreation', 'twoCharacterScenes', 'atoC', 'fiveLineGame']));
    });
  });

  group('exportToJson / importFromJson round-trip', () {
    test('exported backup can be re-imported and fields match', () async {
      final now = DateTime.utc(2024, 7, 15, 12);
      await services.promptRepository.addCustomPrompt(
        CustomPrompt(
          id: 'round-trip-prompt',
          text: 'A clown at a funeral.',
          category: PromptCategory.events,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final original = await backupService.buildBackup();
      final json = await backupService.exportToJson(original);
      final restored = await backupService.importFromJson(json);

      expect(restored.schemaVersion, equals(original.schemaVersion));
      expect(restored.customPrompts, hasLength(original.customPrompts.length));
      expect(restored.customPrompts.first['id'], equals('round-trip-prompt'));
      expect(restored.customPrompts.first['text'], equals('A clown at a funeral.'));
    });
  });

  group('mergeIntoApp()', () {
    test('adds custom prompts not already in the repo', () async {
      final now = DateTime(2024, 8);
      final backup = AppBackup(
        schemaVersion: 1,
        exportedAt: now,
        customPrompts: [
          {
            'id': 'new-prompt-1',
            'text': 'Two people in an elevator.',
            'category': 'events',
            'createdAt': now.toUtc().toIso8601String(),
            'updatedAt': now.toUtc().toIso8601String(),
          },
        ],
        journalEntries: const [],
        drillSettings: const {},
        preferences: const {},
      );

      final result = await backupService.mergeIntoApp(backup);

      expect(result.promptsAdded, equals(1));
      final prompts = await services.promptRepository.getCustomPrompts();
      expect(prompts, hasLength(1));
      expect(prompts.first.id, equals('new-prompt-1'));
    });

    test('skips duplicate custom prompts by id', () async {
      final now = DateTime(2024, 8, 2);
      final existing = CustomPrompt(
        id: 'existing-prompt',
        text: 'Original text',
        category: PromptCategory.objects,
        createdAt: now,
        updatedAt: now,
      );
      await services.promptRepository.addCustomPrompt(existing);

      final backup = AppBackup(
        schemaVersion: 1,
        exportedAt: now,
        customPrompts: [
          {
            'id': 'existing-prompt',
            'text': 'Replacement text that should be ignored',
            'category': 'objects',
            'createdAt': now.toUtc().toIso8601String(),
            'updatedAt': now.toUtc().toIso8601String(),
          },
        ],
        journalEntries: const [],
        drillSettings: const {},
        preferences: const {},
      );

      final result = await backupService.mergeIntoApp(backup);

      expect(result.promptsAdded, equals(0));
      final prompts = await services.promptRepository.getCustomPrompts();
      expect(prompts.first.text, equals('Original text'));
    });

    test('adds journal entries not already in the repo', () async {
      final now = DateTime(2024, 8, 3);
      final backup = AppBackup(
        schemaVersion: 1,
        exportedAt: now,
        customPrompts: const [],
        journalEntries: [
          {
            'id': 'new-entry-1',
            'body': 'Practiced the cat/clock drill today.',
            'createdAt': now.toUtc().toIso8601String(),
            'updatedAt': now.toUtc().toIso8601String(),
            'drillId': null,
          },
        ],
        drillSettings: const {},
        preferences: const {},
      );

      final result = await backupService.mergeIntoApp(backup);

      expect(result.journalEntriesAdded, equals(1));
      final entries = await services.journalRepository.getEntries();
      expect(entries, hasLength(1));
      expect(entries.first.id, equals('new-entry-1'));
    });

    test('skips duplicate journal entries by id', () async {
      final now = DateTime(2024, 8, 4);
      await services.journalRepository.addEntry(
        JournalEntry(
          id: 'existing-entry',
          body: 'Original body',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final backup = AppBackup(
        schemaVersion: 1,
        exportedAt: now,
        customPrompts: const [],
        journalEntries: [
          {
            'id': 'existing-entry',
            'body': 'Replacement body that should be ignored',
            'createdAt': now.toUtc().toIso8601String(),
            'updatedAt': now.toUtc().toIso8601String(),
            'drillId': null,
          },
        ],
        drillSettings: const {},
        preferences: const {},
      );

      final result = await backupService.mergeIntoApp(backup);

      expect(result.journalEntriesAdded, equals(0));
      final entries = await services.journalRepository.getEntries();
      expect(entries.first.body, equals('Original body'));
    });
  });

  group('mergeIntoApp() preferences', () {
    test('restores theme preference and reports settingsUpdated > 0', () async {
      const json = '{"schemaVersion":1,"exportedAt":"2024-01-01T00:00:00.000Z",'
          '"customPrompts":[],"journalEntries":[],"drillSettings":{},'
          '"preferences":{"themePreference":"dark","ttsSpeakingRate":0.5}}';

      final backup = await backupService.importFromJson(json);
      final result = await backupService.mergeIntoApp(backup);

      expect(result.settingsUpdated, greaterThan(0));
      final prefs = await services.appPreferencesRepository.getPreferences();
      expect(prefs.themePreference.name, equals('dark'));
    });
  });

  group('importFromJson() validation', () {
    test('throws FormatException for wrong schemaVersion', () async {
      const badJson =
          '{"schemaVersion":99,"exportedAt":"2024-01-01T00:00:00.000Z",'
          '"customPrompts":[],"journalEntries":[],"drillSettings":{},"preferences":{}}';

      expect(
        () => backupService.importFromJson(badJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for malformed JSON', () async {
      expect(
        () => backupService.importFromJson('{not valid json}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
