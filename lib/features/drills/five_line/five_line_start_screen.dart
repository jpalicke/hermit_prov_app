// ABOUTME: Entry point for the Five Line Game drill — wraps the shared DrillStartScreen.
// ABOUTME: Navigates to configure or session screen based on user action.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/five_line/five_line_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/five_line/five_line_session_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';

class FiveLineStartScreen extends StatelessWidget {
  const FiveLineStartScreen({super.key});

  Future<void> _startSession(BuildContext context) async {
    final services = AppServices.of(context);
    final settings = await services.drillSettingsRepository
        .getSettings(DrillId.fiveLineGame) as FiveLineGameSettings;
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FiveLineSessionScreen(
          settings: settings,
          onSessionEnd: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrillStartScreen(
      drillId: DrillId.fiveLineGame,
      subtitle: 'One prompt, tap for next. Optional auto-advance.',
      onStart: () => _startSession(context),
      onConfigure: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FiveLineConfigureScreen()),
      ),
    );
  }
}
