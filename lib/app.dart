// ABOUTME: Root widget for the Hermit-Prov app.
// ABOUTME: Sets up MaterialApp with light/dark/system theme and bottom navigation shell.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/theme/app_theme.dart';
import 'package:hermit_prov_app/ui/navigation/bottom_nav_shell.dart';

class HermitProvApp extends StatelessWidget {
  const HermitProvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermit-Prov',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('en')],
      home: const BottomNavShell(),
    );
  }
}
