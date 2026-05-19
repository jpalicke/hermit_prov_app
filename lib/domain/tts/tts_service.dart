// ABOUTME: Abstract interface for text-to-speech operations used by the hands-free mode.
// ABOUTME: Implementations swap between a real FlutterTts backend and a test fake.

abstract interface class TtsService {
  /// Speaks [text] aloud. No-op when [isEnabled] is false.
  Future<void> speak(String text);

  /// Stops any current speech immediately.
  Future<void> stop();

  /// Sets the speaking rate. Typical range is 0.25–2.0.
  Future<void> setSpeakingRate(double rate);

  /// True when TTS output is enabled globally. Driven by app preferences.
  bool get isEnabled;
}
