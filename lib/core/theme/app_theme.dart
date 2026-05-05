// ABOUTME: Defines light and dark ThemeData for the Hermit-Prov app.
// ABOUTME: Uses Indie Flower (Google Fonts) throughout with a vivid violet M3 palette.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Bold, saturated violet — generates a full warm-toned M3 palette.
  static const Color _seed = Color(0xFF7C3AED);

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
      textTheme: GoogleFonts.indieFlowerTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
