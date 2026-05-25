// ABOUTME: Configuration screen for the Two-Character Scenes drill.
// ABOUTME: Lets the user adjust scene/regroup durations and prompt category source.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';

class TwoCharacterConfigureScreen extends StatefulWidget {
  const TwoCharacterConfigureScreen({super.key});

  @override
  State<TwoCharacterConfigureScreen> createState() =>
      _TwoCharacterConfigureScreenState();
}

class _TwoCharacterConfigureScreenState
    extends State<TwoCharacterConfigureScreen> {
  TwoCharacterScenesSettings? _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = AppServices.of(context).drillSettingsRepository;
    final settings =
        await repo.getSettings(DrillId.twoCharacterScenes)
            as TwoCharacterScenesSettings;
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _save() async {
    if (_settings == null) return;
    await AppServices.of(context)
        .drillSettingsRepository
        .saveSettings(_settings!);
    if (mounted) Navigator.of(context).pop();
  }

  void _setSceneSeconds(int seconds) {
    setState(() {
      _settings = TwoCharacterScenesSettings(
        sceneDuration: Duration(seconds: seconds),
        regroupDuration: _settings!.regroupDuration,
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setRegroupSeconds(int seconds) {
    setState(() {
      _settings = TwoCharacterScenesSettings(
        sceneDuration: _settings!.sceneDuration,
        regroupDuration: Duration(seconds: seconds),
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setHandsFree(bool value) {
    setState(() {
      _settings = TwoCharacterScenesSettings(
        sceneDuration: _settings!.sceneDuration,
        regroupDuration: _settings!.regroupDuration,
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
      drillId: DrillId.twoCharacterScenes,
      onSave: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scene duration', style: tt.titleMedium),
          const SizedBox(height: 8),
          _DurationRow(
            key: const Key('scene_duration_row'),
            label: 'seconds',
            value: settings.sceneDuration.inSeconds,
            min: 30,
            max: 600,
            step: 30,
            onChanged: _setSceneSeconds,
          ),
          const SizedBox(height: 24),
          Text('Regroup duration', style: tt.titleMedium),
          const SizedBox(height: 8),
          _DurationRow(
            key: const Key('regroup_duration_row'),
            label: 'seconds',
            value: settings.regroupDuration.inSeconds,
            min: 10,
            max: 120,
            step: 10,
            onChanged: _setRegroupSeconds,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            key: const Key('hands_free_toggle'),
            title: const Text('Hands-Free Mode'),
            subtitle: const Text(
                'Speak suggestions and countdown cues aloud during the session'),
            value: settings.handsFreeModeEnabled,
            onChanged: _setHandsFree,
          ),
        ],
      ),
    );
  }
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: Key('${label}_decrement'),
          onPressed: value - step >= min ? () => onChanged(value - step) : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Text(
            '$value $label',
            textAlign: TextAlign.center,
            key: Key('${label}_value'),
          ),
        ),
        IconButton(
          key: Key('${label}_increment'),
          onPressed: value + step <= max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
