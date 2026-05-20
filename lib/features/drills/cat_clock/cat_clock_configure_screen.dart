// ABOUTME: Configuration screen for the Cat/Clock drill.
// ABOUTME: Lets the user adjust speaking/regroup durations and prompt category sources.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
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
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
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
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setHandsFree(bool value) {
    setState(() {
      _settings = CatClockSettings(
        speakingDuration: _settings!.speakingDuration,
        regroupDuration: _settings!.regroupDuration,
        prompt1Categories: _settings!.prompt1Categories,
        prompt2Categories: _settings!.prompt2Categories,
        handsFreeModeEnabled: value,
      );
    });
  }

  void _setPrompt1Categories(List<PromptCategory> categories) {
    setState(() {
      _settings = CatClockSettings(
        speakingDuration: _settings!.speakingDuration,
        regroupDuration: _settings!.regroupDuration,
        prompt1Categories: categories.isEmpty ? [PromptCategory.objects] : categories,
        prompt2Categories: _settings!.prompt2Categories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setPrompt2Categories(List<PromptCategory> categories) {
    setState(() {
      _settings = CatClockSettings(
        speakingDuration: _settings!.speakingDuration,
        regroupDuration: _settings!.regroupDuration,
        prompt1Categories: _settings!.prompt1Categories,
        prompt2Categories: categories.isEmpty ? [PromptCategory.objects] : categories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
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
        onHandsFreeChanged: _setHandsFree,
        onPrompt1CategoriesChanged: _setPrompt1Categories,
        onPrompt2CategoriesChanged: _setPrompt2Categories,
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
    required this.onHandsFreeChanged,
    required this.onPrompt1CategoriesChanged,
    required this.onPrompt2CategoriesChanged,
  });

  final CatClockSettings settings;
  final void Function(int minutes) onSpeakingMinutesChanged;
  final void Function(int seconds) onRegroupSecondsChanged;
  final void Function(bool) onHandsFreeChanged;
  final void Function(List<PromptCategory>) onPrompt1CategoriesChanged;
  final void Function(List<PromptCategory>) onPrompt2CategoriesChanged;

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
        SwitchListTile(
          key: const Key('hands_free_toggle'),
          title: const Text('Hands-Free Mode'),
          subtitle: const Text(
              'Speak prompts and countdown cues aloud during the session'),
          value: settings.handsFreeModeEnabled,
          onChanged: onHandsFreeChanged,
        ),
        const SizedBox(height: 24),
        _CategoryPicker(
          key: const Key('prompt1_category_picker'),
          title: 'Prompt 1 categories',
          selected: settings.prompt1Categories,
          onChanged: onPrompt1CategoriesChanged,
        ),
        const SizedBox(height: 24),
        _CategoryPicker(
          key: const Key('prompt2_category_picker'),
          title: 'Prompt 2 categories',
          selected: settings.prompt2Categories,
          onChanged: onPrompt2CategoriesChanged,
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

// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    super.key,
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<PromptCategory> selected;
  final void Function(List<PromptCategory>) onChanged;

  void _toggle(PromptCategory cat) {
    final next = selected.contains(cat)
        ? selected.where((c) => c != cat).toList()
        : [...selected, cat];
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: PromptCategory.values
              .map((cat) => FilterChip(
                    label: Text(_label(cat)),
                    selected: selected.contains(cat),
                    onSelected: (_) => _toggle(cat),
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _label(PromptCategory cat) => switch (cat) {
    PromptCategory.objects => 'Objects',
    PromptCategory.locations => 'Locations',
    PromptCategory.relationships => 'Relationships',
    PromptCategory.occupations => 'Occupations',
    PromptCategory.emotions => 'Emotions',
    PromptCategory.activities => 'Activities',
    PromptCategory.genre => 'Genre',
    PromptCategory.events => 'Events',
  };
}
