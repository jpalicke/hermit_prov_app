// ABOUTME: Defines light and dark ThemeData for the Hermit-Prov app.
// ABOUTME: Uses a teal/green seed color as a placeholder; final palette set in a later phase.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Placeholder seed color — final palette decided in visual design phase.
  static const Color _seedColor = Color(0xFF2E7D5B);

  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
