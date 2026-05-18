// ABOUTME: Entry point for the Cat/Clock drill — wraps the shared DrillStartScreen.
// ABOUTME: Navigates to the configure or session screen based on user action.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_session_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';

class CatClockStartScreen extends StatelessWidget {
  const CatClockStartScreen({super.key});

  Future<void> _startSession(BuildContext context) async {
    final services = AppServices.of(context);
    final settings = await services.drillSettingsRepository
        .getSettings(DrillId.catClock) as CatClockSettings;
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatClockSessionScreen(
          settings: settings,
          promptRepository: services.promptRepository,
          onSessionEnd: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _openConfigure(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CatClockConfigureScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrillStartScreen(
      drillId: DrillId.catClock,
      subtitle:
          'Two prompts, speaking rep, short regroup. Loops until you stop.',
      onStart: () => _startSession(context),
      onConfigure: () => _openConfigure(context),
    );
  }
}
