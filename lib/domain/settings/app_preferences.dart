// ABOUTME: Model holding global app preferences stored locally on device.
// ABOUTME: Covers theme, TTS voice, and speaking rate. Defaults to system theme.

import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';

class AppPreferences {
  const AppPreferences({
    this.themePreference = AppThemePreference.system,
    this.ttsVoice,
    this.ttsSpeakingRate = 1.0,
  });

  final AppThemePreference themePreference;
  final String? ttsVoice;
  final double ttsSpeakingRate;

  static const AppPreferences defaults = AppPreferences();
}
