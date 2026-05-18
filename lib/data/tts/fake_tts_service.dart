// ABOUTME: In-memory TTS service for use in widget and unit tests.
// ABOUTME: Captures spoken text and stop calls without invoking any real TTS engine.

import 'package:hermit_prov_app/domain/tts/tts_service.dart';

/// Test-only TTS service that records all speak/stop calls in memory.
class FakeTtsService implements TtsService {
  /// All text strings that were passed to [speak] in call order.
  final List<String> spoken = [];

  /// Number of times [stop] has been called.
  int stopCount = 0;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<List<String>> getAvailableVoices() async => [];

  @override
  Future<void> setSpeakingRate(double rate) async {}

  @override
  Future<void> setVoice(String voice) async {}

  @override
  bool get isEnabled => true;
}
