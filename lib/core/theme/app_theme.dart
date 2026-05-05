// ABOUTME: Defines light and dark ThemeData for the Hermit-Prov app.
// ABOUTME: Uses bundled Indie Flower font throughout with a vivid violet M3 palette.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Bold, saturated violet — generates a full warm-toned M3 palette.
  static const Color _seed = Color(0xFF7C3AED);

  static const String _fontFamily = 'IndieFlower';

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: _fontFamily),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
