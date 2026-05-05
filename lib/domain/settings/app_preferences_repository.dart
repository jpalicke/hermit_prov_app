// ABOUTME: Repository interface for persisting and retrieving global app preferences.
// ABOUTME: Returns AppPreferences.defaults when no preferences have been saved yet.

import 'package:hermit_prov_app/domain/settings/app_preferences.dart';

abstract interface class AppPreferencesRepository {
  Future<AppPreferences> getPreferences();
  Future<void> savePreferences(AppPreferences preferences);
}
