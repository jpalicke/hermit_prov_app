// ABOUTME: Settings screen for configuring Text-to-Speech speaking rate and voice.
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
  List<String> _voices = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefs == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final services = AppServices.of(context);
    final prefs = await services.appPreferencesRepository.getPreferences();
    final voices = await services.ttsService.getAvailableVoices();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _voices = voices;
      });
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
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rateLabel =
        '${prefs.ttsSpeakingRate.toStringAsFixed(1)}x';

    return Scaffold(
      appBar: AppBar(title: const Text('Text-to-Speech')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Speaking rate ──────────────────────────────────────────────────
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
              final updated = AppPreferences(
                themePreference: prefs.themePreference,
                ttsVoice: prefs.ttsVoice,
                ttsSpeakingRate: v,
              );
              _savePrefs(updated);
            },
          ),
          const Divider(),
          // ── Voice selector ─────────────────────────────────────────────────
          if (_voices.isEmpty)
            const ListTile(
              key: Key('tts_voice_default'),
              title: Text('Voice'),
              subtitle: Text('Default voice'),
            )
          else
            ListTile(
              title: const Text('Voice'),
              trailing: DropdownButton<String>(
                key: const Key('tts_voice_dropdown'),
                value: prefs.ttsVoice ?? _voices.first,
                items: _voices
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (selected) {
                  if (selected == null) return;
                  final updated = AppPreferences(
                    themePreference: prefs.themePreference,
                    ttsVoice: selected,
                    ttsSpeakingRate: prefs.ttsSpeakingRate,
                  );
                  _savePrefs(updated);
                },
              ),
            ),
        ],
      ),
    );
  }
}
