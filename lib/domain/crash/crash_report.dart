// ABOUTME: Value object representing a sanitized crash report.
// ABOUTME: Explicitly excludes user data — no custom prompts, journal entries, or audio.

class CrashReport {
  const CrashReport({
    required this.errorSummary,
    required this.stackTrace,
    required this.appVersion,
    required this.deviceOs,
    this.activeScreen,
    this.activeDrill,
  });

  final String errorSummary;
  final String stackTrace;
  final String appVersion;
  final String deviceOs;

  /// The screen that was active when the crash occurred, if known.
  final String? activeScreen;

  /// The drill that was active when the crash occurred, if known.
  final String? activeDrill;

  // Explicitly no custom prompts, no journal entries, no audio.
}
