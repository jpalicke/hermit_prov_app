// ABOUTME: Settings screen with sections for appearance, TTS, drill defaults, and data management.
// ABOUTME: Loads and persists preferences via AppServices repositories.

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/backup/local_backup_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';
import 'package:hermit_prov_app/features/settings/tts_settings_screen.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppPreferences? _prefs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefs == null) {
      _loadPreferences();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await AppServices.of(context)
        .appPreferencesRepository
        .getPreferences();
    if (mounted) {
      setState(() => _prefs = prefs);
    }
  }

  Future<void> _saveTheme(AppThemePreference pref) async {
    final services = AppServices.of(context);
    final current = _prefs ?? AppPreferences.defaults;
    final updated = AppPreferences(
      themePreference: pref,
      ttsVoice: current.ttsVoice,
      ttsSpeakingRate: current.ttsSpeakingRate,
    );
    await services.appPreferencesRepository.savePreferences(updated);
    services.themeNotifier.value = pref.toThemeMode();
    if (mounted) setState(() => _prefs = updated);
  }

  Future<void> _confirmResetDrillDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Drill Defaults?'),
        content: const Text(
          'This will restore all drill settings to their original defaults. '
          'Your custom prompts, journal, and history will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _resetDrillDefaults();
    }
  }

  Future<void> _resetDrillDefaults() async {
    final repo = AppServices.of(context).drillSettingsRepository;
    for (final id in DrillId.values) {
      await repo.resetToDefaults(id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drill defaults restored.')),
      );
    }
  }

  LocalBackupService _makeBackupService() {
    final services = AppServices.of(context);
    return LocalBackupService(
      promptRepository: services.promptRepository,
      journalRepository: services.journalRepository,
      drillSettingsRepository: services.drillSettingsRepository,
      appPreferencesRepository: services.appPreferencesRepository,
    );
  }

  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final svc = _makeBackupService();
      final backup = await svc.buildBackup();
      final json = await svc.exportToJson(backup);

      final now = DateTime.now();
      final datePart =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final fileName = 'hermit_prov_backup_$datePart.json';

      final bytes = Uint8List.fromList(json.codeUnits);
      final xFile = XFile.fromData(bytes, name: fileName, mimeType: 'application/json');
      await Share.shareXFiles([xFile], fileNameOverrides: [fileName]);

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Backup exported.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final String jsonString;
      if (file.bytes != null) {
        jsonString = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        // On desktop/mobile with path access, read via XFile.
        final xFile = XFile(file.path!);
        jsonString = await xFile.readAsString();
      } else {
        throw const FormatException('Could not read the selected file.');
      }

      final svc = _makeBackupService();
      final backup = await svc.importFromJson(jsonString);
      final mergeResult = await svc.mergeIntoApp(backup);

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Added ${mergeResult.promptsAdded} prompts, '
              '${mergeResult.journalEntriesAdded} journal entries.',
            ),
          ),
        );
      }
    } on FormatException {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Import failed: invalid backup file.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmResetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all custom prompts, journal entries, '
          'and practice history, and reset all settings to defaults. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _resetAllData();
    }
  }

  Future<void> _resetAllData() async {
    final services = AppServices.of(context);
    await services.promptRepository.clearAll();
    await services.journalRepository.clearAll();
    await services.practiceHistoryRepository.clearAll();
    await services.appPreferencesRepository
        .savePreferences(AppPreferences.defaults);
    for (final id in DrillId.values) {
      await services.drillSettingsRepository.resetToDefaults(id);
    }
    services.themeNotifier.value = ThemeMode.system;
    if (mounted) {
      setState(() => _prefs = AppPreferences.defaults);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs ?? AppPreferences.defaults;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
          // ── Appearance ────────────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          _ThemeSelector(
            selected: prefs.themePreference,
            onChanged: _saveTheme,
          ),

          // ── Text-to-Speech ────────────────────────────────────────────────
          _SectionHeader(title: 'Text-to-Speech'),
          ListTile(
            title: const Text('Text-to-Speech'),
            subtitle: const Text('Voice and speaking rate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TtsSettingsScreen(),
                ),
              );
            },
          ),

          // ── Drill Defaults ────────────────────────────────────────────────
          _SectionHeader(title: 'Drill Defaults'),
          ListTile(
            title: const Text('Reset Drill Defaults'),
            subtitle: const Text(
                'Restore all drill timings and options to defaults'),
            onTap: _confirmResetDrillDefaults,
          ),

          // ── Data Backup ───────────────────────────────────────────────────
          _SectionHeader(title: 'Data Backup'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Data stays on this device unless you export it. '
                  'Uninstalling the app or switching devices may delete your local data.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Save a JSON backup of your prompts, journal, and settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          ListTile(
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a JSON backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _importData,
          ),

          // ── Privacy / About ───────────────────────────────────────────────
          _SectionHeader(title: 'Privacy and About'),
          const ListTile(
            title: Text('Privacy and About'),
            subtitle: Text('Coming soon.'),
          ),

          // ── Support ───────────────────────────────────────────────────────
          _SectionHeader(title: 'Support'),
          const ListTile(
            title: Text('Support and Donate'),
            subtitle: Text('Coming soon.'),
          ),

          // ── Reset All Data (danger zone) ──────────────────────────────────
          _SectionHeader(
            title: 'Reset All Data',
            color: colorScheme.error,
          ),
          Semantics(
            button: true,
            label: 'Reset All Data',
            hint: 'Permanently deletes all custom prompts, journal entries, practice history, and resets settings. This action cannot be undone.',
            child: ListTile(
              key: const Key('reset_all_data_tile'),
              title: Text(
                'Reset All Data',
                style: TextStyle(color: colorScheme.error),
              ),
              subtitle: const Text(
                  'Permanently delete all data and reset preferences'),
              onTap: _confirmResetAllData,
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

// ── _SectionHeader ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.color});

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: textTheme.labelMedium?.copyWith(
            color: color ?? colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── _ThemeSelector ─────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selected,
    required this.onChanged,
  });

  final AppThemePreference selected;
  final ValueChanged<AppThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<AppThemePreference>(
      groupValue: selected,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      child: Column(
        children: AppThemePreference.values.map((pref) {
          return RadioListTile<AppThemePreference>(
            title: Text(_labelFor(pref)),
            value: pref,
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(AppThemePreference pref) => switch (pref) {
        AppThemePreference.system => 'System Default',
        AppThemePreference.light => 'Light',
        AppThemePreference.dark => 'Dark',
      };
}
