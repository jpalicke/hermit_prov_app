// ABOUTME: Real TTS service backed by the flutter_tts package.
// ABOUTME: Reads speaking rate from AppPreferences on each speak call; uses system default voice.

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
    // flutter_tts maps 0.5 to the platform default rate; scale accordingly.
    await _tts.setSpeechRate(prefs.ttsSpeakingRate * 0.5);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> setSpeakingRate(double rate) async {
    await _tts.setSpeechRate(rate * 0.5);
  }
}
