// ABOUTME: Tools-only app shell for the Hermit Prov web build.
// ABOUTME: Mounts ToolsScreen directly with in-memory services; no drills, no persistent history.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/core/theme/app_theme.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

class HermitProvWebApp extends StatelessWidget {
  const HermitProvWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppServices.withInMemory(
      child: const _WebMaterialApp(),
    );
  }
}

class _WebMaterialApp extends StatelessWidget {
  const _WebMaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermit Prov Tools',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // ThemeMode.system intentionally; web build has no Settings screen to change it.
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('en')],
      home: const ToolsScreen(),
    );
  }
}
