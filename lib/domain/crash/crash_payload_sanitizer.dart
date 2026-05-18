// ABOUTME: Pure-Dart class that constructs a sanitized CrashReport from raw crash data.
// ABOUTME: Intentionally accepts no user content parameters — prompts and journal data must never reach this class.

import 'package:hermit_prov_app/domain/crash/crash_report.dart';

class CrashPayloadSanitizer {
  const CrashPayloadSanitizer();

  /// Builds a [CrashReport] from the provided technical details.
  ///
  /// Note: intentionally no prompt/journal params — they must never reach this method.
  CrashReport sanitize({
    required String errorSummary,
    required String stackTrace,
    required String appVersion,
    required String deviceOs,
    String? activeScreen,
    String? activeDrill,
  }) {
    return CrashReport(
      errorSummary: errorSummary,
      stackTrace: stackTrace,
      appVersion: appVersion,
      deviceOs: deviceOs,
      activeScreen: activeScreen,
      activeDrill: activeDrill,
    );
  }
}
