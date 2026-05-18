// ABOUTME: Configuration screen for the A-to-C / Bad Idea / Initiation drill.
// ABOUTME: Lets the user pick one of the four allowed intervals (15/30/45/60s).

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';

class AtoCConfigureScreen extends StatefulWidget {
  const AtoCConfigureScreen({super.key});

  @override
  State<AtoCConfigureScreen> createState() => _AtoCConfigureScreenState();
}

class _AtoCConfigureScreenState extends State<AtoCConfigureScreen> {
  AtoCSettings? _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = AppServices.of(context).drillSettingsRepository;
    final s = await repo.getSettings(DrillId.atoC) as AtoCSettings;
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _save() async {
    if (_settings == null) return;
    await AppServices.of(context)
        .drillSettingsRepository
        .saveSettings(_settings!);
    if (mounted) Navigator.of(context).pop();
  }

  void _setHandsFree(bool value) {
    setState(() {
      _settings = AtoCSettings(
        interval: _settings!.interval,
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
      drillId: DrillId.atoC,
      onSave: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interval', style: tt.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AtoCSettings.allowedIntervals.map((d) {
              final isSelected = settings.interval == d;
              return ChoiceChip(
                key: Key('interval_${d.inSeconds}s'),
                label: Text('${d.inSeconds}s'),
                selected: isSelected,
                onSelected: (_) => setState(() {
                  _settings = AtoCSettings(
                    interval: d,
                    promptCategories: settings.promptCategories,
                    handsFreeModeEnabled: settings.handsFreeModeEnabled,
                  );
                }),
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
