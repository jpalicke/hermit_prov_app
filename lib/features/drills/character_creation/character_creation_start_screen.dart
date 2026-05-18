// ABOUTME: Entry point for the Character Creation drill — wraps shared DrillStartScreen.
// ABOUTME: Navigates to configure or session screen based on user action.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/character_creation/character_creation_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/character_creation/character_creation_session_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';

class CharacterCreationStartScreen extends StatelessWidget {
  const CharacterCreationStartScreen({super.key});

  Future<void> _startSession(BuildContext context) async {
    final services = AppServices.of(context);
    final settings = await services.drillSettingsRepository
        .getSettings(DrillId.characterCreation)
        as CharacterCreationSettings;
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterCreationSessionScreen(
          settings: settings,
          onSessionEnd: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrillStartScreen(
      drillId: DrillId.characterCreation,
      subtitle: 'Build solo characters in timed passes. Ends after full cycle.',
      onStart: () => _startSession(context),
      onConfigure: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const CharacterCreationConfigureScreen()),
      ),
    );
  }
}
