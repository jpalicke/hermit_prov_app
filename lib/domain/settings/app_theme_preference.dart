// ABOUTME: Enum for the user's preferred app theme.
// ABOUTME: Persisted via AppPreferences and applied at the MaterialApp level.

import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark,
}

extension AppThemePreferenceToThemeMode on AppThemePreference {
  /// Converts this preference to the corresponding Flutter [ThemeMode].
  ThemeMode toThemeMode() => switch (this) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };
}
