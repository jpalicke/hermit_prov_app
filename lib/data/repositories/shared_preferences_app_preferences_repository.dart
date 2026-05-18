// ABOUTME: SharedPreferences-backed implementation of AppPreferencesRepository.
// ABOUTME: Stores theme, TTS voice, and speaking rate as individual preference keys.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';

class SharedPreferencesAppPreferencesRepository
    implements AppPreferencesRepository {
  SharedPreferencesAppPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _keyTheme = 'app_theme_preference';
  static const _keyTtsVoice = 'tts_voice';
  static const _keyTtsSpeakingRate = 'tts_speaking_rate';

  @override
  Future<AppPreferences> getPreferences() async {
    final themeStr = _prefs.getString(_keyTheme);
    final theme = themeStr == null
        ? AppThemePreference.system
        : AppThemePreference.values.byName(themeStr);
    final ttsVoice = _prefs.getString(_keyTtsVoice);
    final ttsSpeakingRate =
        _prefs.getDouble(_keyTtsSpeakingRate) ?? AppPreferences.defaults.ttsSpeakingRate;
    return AppPreferences(
      themePreference: theme,
      ttsVoice: ttsVoice,
      ttsSpeakingRate: ttsSpeakingRate,
    );
  }

  @override
  Future<void> savePreferences(AppPreferences preferences) async {
    await _prefs.setString(_keyTheme, preferences.themePreference.name);
    if (preferences.ttsVoice != null) {
      await _prefs.setString(_keyTtsVoice, preferences.ttsVoice!);
    } else {
      await _prefs.remove(_keyTtsVoice);
    }
    await _prefs.setDouble(_keyTtsSpeakingRate, preferences.ttsSpeakingRate);
  }
}
