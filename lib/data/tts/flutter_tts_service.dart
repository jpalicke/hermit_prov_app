// ABOUTME: Real TTS service backed by the flutter_tts package.
// ABOUTME: Reads speaking rate from AppPreferences on each speak call.

import 'package:flutter_tts/flutter_tts.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';

class FlutterTtsService implements TtsService {
  FlutterTtsService({
    required AppPreferencesRepository preferencesRepository,
    required bool enabled,
  })  : _preferencesRepository = preferencesRepository,
        _isEnabled = enabled {
    _tts = FlutterTts();
  }

  final AppPreferencesRepository _preferencesRepository;
  final bool _isEnabled;
  late final FlutterTts _tts;

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    final prefs = await _preferencesRepository.getPreferences();
    await _tts.setSpeechRate(prefs.ttsSpeakingRate);
    if (prefs.ttsVoice != null) {
      await _tts.setVoice({'name': prefs.ttsVoice!, 'locale': 'en-US'});
    }
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<List<String>> getAvailableVoices() async {
    final raw = await _tts.getVoices;
    if (raw == null) return [];
    final voices = <String>[];
    for (final v in raw) {
      if (v is Map) {
        final name = v['name'];
        if (name is String) voices.add(name);
      }
    }
    return voices;
  }

  @override
  Future<void> setSpeakingRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  @override
  Future<void> setVoice(String voice) async {
    await _tts.setVoice({'name': voice, 'locale': 'en-US'});
  }
}
