// ABOUTME: Entry point for the A-to-C / Bad Idea / Initiation drill.
// ABOUTME: Navigates to configure or session screen based on user action.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_session_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';

class AtoCStartScreen extends StatelessWidget {
  const AtoCStartScreen({super.key});

  Future<void> _startSession(BuildContext context) async {
    final services = AppServices.of(context);
    final settings = await services.drillSettingsRepository
        .getSettings(DrillId.atoC) as AtoCSettings;
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AtoCSessionScreen(
          settings: settings,
          promptRepository: services.promptRepository,
          onSessionEnd: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrillStartScreen(
      drillId: DrillId.atoC,
      subtitle: 'One prompt per interval. Loops until stopped.',
      onStart: () => _startSession(context),
      onConfigure: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AtoCConfigureScreen()),
      ),
    );
  }
}
