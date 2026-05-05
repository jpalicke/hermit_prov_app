// ABOUTME: In-memory implementation of AppPreferencesRepository.
// ABOUTME: Returns AppPreferences.defaults until preferences are explicitly saved.

import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';

class InMemoryAppPreferencesRepository implements AppPreferencesRepository {
  AppPreferences _prefs = AppPreferences.defaults;

  @override
  Future<AppPreferences> getPreferences() async => _prefs;

  @override
  Future<void> savePreferences(AppPreferences preferences) async {
    _prefs = preferences;
  }
}
