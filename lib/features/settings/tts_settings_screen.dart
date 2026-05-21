// ABOUTME: Settings screen for configuring Text-to-Speech speaking rate.
// ABOUTME: Changes auto-save on change; no explicit save button needed.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';

class TtsSettingsScreen extends StatefulWidget {
  const TtsSettingsScreen({super.key});

  @override
  State<TtsSettingsScreen> createState() => _TtsSettingsScreenState();
}

class _TtsSettingsScreenState extends State<TtsSettingsScreen> {
  AppPreferences? _prefs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefs == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final prefs = await AppServices.of(context).appPreferencesRepository.getPreferences();
    if (mounted) {
      setState(() => _prefs = prefs);
    }
  }

  Future<void> _savePrefs(AppPreferences updated) async {
    await AppServices.of(context)
        .appPreferencesRepository
        .savePreferences(updated);
    if (mounted) setState(() => _prefs = updated);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    if (prefs == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rateLabel = '${prefs.ttsSpeakingRate.toStringAsFixed(1)}x';

    return Scaffold(
      appBar: AppBar(title: const Text('Text-to-Speech')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            title: const Text('Speaking Rate'),
            subtitle: Text(rateLabel),
          ),
          Slider(
            key: const Key('tts_rate_slider'),
            value: prefs.ttsSpeakingRate,
            min: AppPreferences.minSpeakingRate,
            max: AppPreferences.maxSpeakingRate,
            divisions: 7,
            label: rateLabel,
            onChanged: (v) {
              _savePrefs(AppPreferences(
                themePreference: prefs.themePreference,
                ttsSpeakingRate: v,
              ));
            },
          ),
        ],
      ),
    );
  }
}
