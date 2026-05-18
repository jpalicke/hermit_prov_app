// ABOUTME: Entry point for the Two-Character Scenes drill — wraps the shared DrillStartScreen.
// ABOUTME: Navigates to configure or session screen based on user action.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_session_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';

class TwoCharacterStartScreen extends StatelessWidget {
  const TwoCharacterStartScreen({super.key});

  Future<void> _startSession(BuildContext context) async {
    final services = AppServices.of(context);
    final settings = await services.drillSettingsRepository
        .getSettings(DrillId.twoCharacterScenes)
        as TwoCharacterScenesSettings;
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TwoCharacterSessionScreen(
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
      drillId: DrillId.twoCharacterScenes,
      subtitle: 'One prompt, timed scene, short regroup. Loops until stopped.',
      onStart: () => _startSession(context),
      onConfigure: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const TwoCharacterConfigureScreen()),
      ),
    );
  }
}
