// ABOUTME: Configuration screen for the Five Line Game drill.
// ABOUTME: Toggles auto-advance on/off and picks the advance interval.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';

class FiveLineConfigureScreen extends StatefulWidget {
  const FiveLineConfigureScreen({super.key});

  @override
  State<FiveLineConfigureScreen> createState() =>
      _FiveLineConfigureScreenState();
}

class _FiveLineConfigureScreenState extends State<FiveLineConfigureScreen> {
  FiveLineGameSettings? _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = AppServices.of(context).drillSettingsRepository;
    final s = await repo.getSettings(DrillId.fiveLineGame) as FiveLineGameSettings;
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _save() async {
    if (_settings == null) return;
    await AppServices.of(context)
        .drillSettingsRepository
        .saveSettings(_settings!);
    if (mounted) Navigator.of(context).pop();
  }

  void _setAutoAdvance(bool value) {
    setState(() {
      _settings = FiveLineGameSettings(
        autoAdvance: value,
        autoAdvanceInterval: _settings!.autoAdvanceInterval ??
            FiveLineGameSettings.allowedAutoAdvanceIntervals.first,
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setInterval(Duration d) {
    setState(() {
      _settings = FiveLineGameSettings(
        autoAdvance: _settings!.autoAdvance,
        autoAdvanceInterval: d,
        promptCategories: _settings!.promptCategories,
        handsFreeModeEnabled: _settings!.handsFreeModeEnabled,
      );
    });
  }

  void _setHandsFree(bool value) {
    setState(() {
      _settings = FiveLineGameSettings(
        autoAdvance: _settings!.autoAdvance,
        autoAdvanceInterval: _settings!.autoAdvanceInterval,
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
      drillId: DrillId.fiveLineGame,
      onSave: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            key: const Key('auto_advance_toggle'),
            title: const Text('Auto-advance'),
            subtitle: const Text(
                'Automatically show a new prompt at each interval'),
            value: settings.autoAdvance,
            onChanged: _setAutoAdvance,
          ),
          if (settings.autoAdvance) ...[
            const SizedBox(height: 16),
            Text('Auto-advance interval', style: tt.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  FiveLineGameSettings.allowedAutoAdvanceIntervals.map((d) {
                final selected = (settings.autoAdvanceInterval ?? d) == d;
                return ChoiceChip(
                  key: Key('interval_${d.inSeconds}s'),
                  label: Text('${d.inSeconds}s'),
                  selected: selected,
                  onSelected: (_) => _setInterval(d),
                );
              }).toList(),
            ),
          ],
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
