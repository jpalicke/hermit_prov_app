// ABOUTME: Repository tests for SharedPreferencesAppPreferencesRepository.
// ABOUTME: Uses SharedPreferences' built-in in-memory store to check defaults, round-trip and stored keys.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/shared_preferences_app_preferences_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('returns defaults when nothing has been stored', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPreferencesAppPreferencesRepository(
      await SharedPreferences.getInstance(),
    );

    final prefs = await repo.getPreferences();

    expect(prefs.themePreference, AppThemePreference.system);
    expect(prefs.ttsSpeakingRate, AppPreferences.defaults.ttsSpeakingRate);
  });

  test('reads values stored under the existing keys', () async {
    // Pins the on-device keys: renaming them would reset users' settings.
    SharedPreferences.setMockInitialValues({
      'app_theme_preference': 'dark',
      'tts_speaking_rate': 1.5,
    });
    final repo = SharedPreferencesAppPreferencesRepository(
      await SharedPreferences.getInstance(),
    );

    final prefs = await repo.getPreferences();

    expect(prefs.themePreference, AppThemePreference.dark);
    expect(prefs.ttsSpeakingRate, 1.5);
  });

  test('saved preferences read back unchanged', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPreferencesAppPreferencesRepository(
      await SharedPreferences.getInstance(),
    );

    await repo.savePreferences(
      const AppPreferences(
        themePreference: AppThemePreference.light,
        ttsSpeakingRate: 0.75,
      ),
    );
    final prefs = await repo.getPreferences();

    expect(prefs.themePreference, AppThemePreference.light);
    expect(prefs.ttsSpeakingRate, 0.75);
  });
}
