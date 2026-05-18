// ABOUTME: Configuration screen for the Cat/Clock drill.
// ABOUTME: Lets the user adjust speaking/regroup durations and prompt category sources.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';

class CatClockConfigureScreen extends StatefulWidget {
  const CatClockConfigureScreen({super.key});

  @override
  State<CatClockConfigureScreen> createState() =>
      _CatClockConfigureScreenState();
}

class _CatClockConfigureScreenState extends State<CatClockConfigureScreen> {
  CatClockSettings? _settings;

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
        await repo.getSettings(DrillId.catClock) as CatClockSettings;
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _save() async {
    if (_settings == null) return;
    await AppServices.of(context)
        .drillSettingsRepository
        .saveSettings(_settings!);
    if (mounted) Navigator.of(context).pop();
  }

  void _setSpeakingMinutes(int minutes) {
    setState(() {
      _settings = CatClockSettings(
        speakingDuration: Duration(minutes: minutes),
        regroupDuration: _settings!.regroupDuration,
        prompt1Categories: _settings!.prompt1Categories,
        prompt2Categories: _settings!.prompt2Categories,
      );
    });
  }

  void _setRegroupSeconds(int seconds) {
    setState(() {
      _settings = CatClockSettings(
        speakingDuration: _settings!.speakingDuration,
        regroupDuration: Duration(seconds: seconds),
        prompt1Categories: _settings!.prompt1Categories,
        prompt2Categories: _settings!.prompt2Categories,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DrillConfigureScreen(
      drillId: DrillId.catClock,
      onSave: _save,
      body: _CatClockConfigBody(
        settings: settings,
        onSpeakingMinutesChanged: _setSpeakingMinutes,
        onRegroupSecondsChanged: _setRegroupSeconds,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CatClockConfigBody extends StatelessWidget {
  const _CatClockConfigBody({
    required this.settings,
    required this.onSpeakingMinutesChanged,
    required this.onRegroupSecondsChanged,
  });

  final CatClockSettings settings;
  final void Function(int minutes) onSpeakingMinutesChanged;
  final void Function(int seconds) onRegroupSecondsChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Speaking duration', style: tt.titleMedium),
        const SizedBox(height: 8),
        _DurationPicker(
          key: const Key('speaking_duration_picker'),
          label: 'minutes',
          value: settings.speakingDuration.inMinutes,
          min: 1,
          max: 10,
          onChanged: onSpeakingMinutesChanged,
        ),
        const SizedBox(height: 24),
        Text('Regroup duration', style: tt.titleMedium),
        const SizedBox(height: 8),
        _DurationPicker(
          key: const Key('regroup_duration_picker'),
          label: 'seconds',
          value: settings.regroupDuration.inSeconds,
          min: 10,
          max: 120,
          step: 10,
          onChanged: onRegroupSecondsChanged,
        ),
        const SizedBox(height: 24),
        // Hands-Free toggle — placeholder, no TTS yet.
        Text('Hands-Free (coming soon)', style: tt.titleMedium),
        const SizedBox(height: 8),
        const SwitchListTile(
          key: Key('hands_free_toggle'),
          title: Text('Hands-Free mode'),
          subtitle: Text('TTS not yet available'),
          value: false,
          onChanged: null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
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
          onPressed:
              value - step >= min ? () => onChanged(value - step) : null,
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
          onPressed:
              value + step <= max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
