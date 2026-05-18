// ABOUTME: Configuration screen for the Character Creation drill.
// ABOUTME: Allows setting character count (2-5), segment duration (60/90/120s), and category.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';

class CharacterCreationConfigureScreen extends StatefulWidget {
  const CharacterCreationConfigureScreen({super.key});

  @override
  State<CharacterCreationConfigureScreen> createState() =>
      _CharacterCreationConfigureScreenState();
}

class _CharacterCreationConfigureScreenState
    extends State<CharacterCreationConfigureScreen> {
  CharacterCreationSettings? _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = AppServices.of(context).drillSettingsRepository;
    final s = await repo.getSettings(DrillId.characterCreation)
        as CharacterCreationSettings;
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _save() async {
    if (_settings == null) return;
    await AppServices.of(context)
        .drillSettingsRepository
        .saveSettings(_settings!);
    if (mounted) Navigator.of(context).pop();
  }

  void _setCharacterCount(int count) {
    setState(() {
      _settings = CharacterCreationSettings(
        characterCount: count,
        segmentDuration: _settings!.segmentDuration,
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setSegmentDuration(Duration d) {
    setState(() {
      _settings = CharacterCreationSettings(
        characterCount: _settings!.characterCount,
        segmentDuration: d,
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setHandsFree(bool value) {
    setState(() {
      _settings = CharacterCreationSettings(
        characterCount: _settings!.characterCount,
        segmentDuration: _settings!.segmentDuration,
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tt = Theme.of(context).textTheme;

    return DrillConfigureScreen(
      drillId: DrillId.characterCreation,
      onSave: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Number of characters', style: tt.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                CharacterCreationSettings.allowedCharacterCounts.map((c) {
              return ChoiceChip(
                key: Key('character_count_$c'),
                label: Text('$c'),
                selected: settings.characterCount == c,
                onSelected: (_) => _setCharacterCount(c),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Segment duration', style: tt.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                CharacterCreationSettings.allowedSegmentDurations.map((d) {
              return ChoiceChip(
                key: Key('segment_duration_${d.inSeconds}s'),
                label: Text('${d.inSeconds}s'),
                selected: settings.segmentDuration == d,
                onSelected: (_) => _setSegmentDuration(d),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            key: const Key('hands_free_toggle'),
            title: const Text('Hands-Free Mode'),
            subtitle: const Text(
                'Speak prompts and countdown cues aloud during the session'),
            value: settings.handsFreeModeEnabled,
            onChanged: _setHandsFree,
          ),
        ],
      ),
    );
  }
}
