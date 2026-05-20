// ABOUTME: Root widget for the Hermit Prov app.
// ABOUTME: Sets up MaterialApp with light/dark/system theme and bottom navigation shell.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/core/theme/app_theme.dart';
import 'package:hermit_prov_app/ui/navigation/bottom_nav_shell.dart';

// Global key that lets the crash handler in main.dart reach a navigator
// context when FlutterError.onError fires outside the widget lifecycle.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class HermitProvApp extends StatefulWidget {
  const HermitProvApp({super.key});

  @override
  State<HermitProvApp> createState() => _HermitProvAppState();
}

class _HermitProvAppState extends State<HermitProvApp> {
  ValueNotifier<ThemeMode>? _themeNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = _findThemeNotifier();
    if (notifier != null && notifier != _themeNotifier) {
      _themeNotifier?.removeListener(_onThemeChanged);
      _themeNotifier = notifier;
      _themeNotifier!.addListener(_onThemeChanged);
    }
  }

  ValueNotifier<ThemeMode>? _findThemeNotifier() {
    final services =
        context.dependOnInheritedWidgetOfExactType<AppServices>();
    return services?.themeNotifier;
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _themeNotifier?.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = _themeNotifier?.value ?? ThemeMode.system;
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Hermit Prov',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      supportedLocales: const [Locale('en')],
      home: const BottomNavShell(),
    );
  }
}
