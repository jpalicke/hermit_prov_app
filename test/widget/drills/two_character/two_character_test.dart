// ABOUTME: Widget tests for the Two-Character Scenes drill.
// ABOUTME: Verifies session → no character labels, configure, and stop confirmation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_session_screen.dart';

Widget _wrapSession({VoidCallback? onSessionEnd}) {
  return AppServices.withInMemory(
    child: Builder(
      builder: (context) {
        final services = AppServices.of(context);
        return MaterialApp(
          home: TwoCharacterSessionScreen(
            settings: const TwoCharacterScenesSettings(),
            promptRepository: services.promptRepository,
            onSessionEnd: onSessionEnd ?? () {},
          ),
        );
      },
    ),
  );
}

void main() {
  // 1. Session shows session shell controls.
  testWidgets('Session launches session shell', (tester) async {
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Session loads idle — Start button shown before clock begins.
    expect(find.byKey(const Key('start_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_end_button')), findsOneWidget);

    // After tapping Start, Pause/Resume button appears.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
  });

  // 2. No character speaker labels anywhere.
  testWidgets('Session screen has no character speaker labels', (tester) async {
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Make sure no "Character 1", "Character 2", "Speaker", etc. appear.
    expect(find.textContaining('Character 1'), findsNothing);
    expect(find.textContaining('Character 2'), findsNothing);
    expect(find.textContaining('Speaker'), findsNothing);
  });

  // 3. Hands-Free toggle is present and off by default in configure screen.
  testWidgets('Configure has Hands-Free toggle off by default', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: TwoCharacterConfigureScreen()),
      ),
    );
    await tester.pump();

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('hands_free_toggle')),
    );
    expect(toggle.value, isFalse);
  });

  // 4. Configure saves timer/category settings.
  testWidgets('Configure saves scene duration', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: TwoCharacterConfigureScreen()),
      ),
    );
    await tester.pump();

    // Increment scene duration by one step (90 + 30 = 120 seconds).
    await tester.tap(find.byKey(const Key('seconds_increment')).first);
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(ctx).drillSettingsRepository;
    final saved =
        await repo.getSettings(DrillId.twoCharacterScenes)
            as TwoCharacterScenesSettings;
    expect(saved.sceneDuration, const Duration(seconds: 120));
  });

  // 4. Stop calls onSessionEnd immediately without a confirmation dialog.
  testWidgets('Stop calls onSessionEnd immediately', (tester) async {
    var ended = false;
    await tester.pumpWidget(_wrapSession(onSessionEnd: () => ended = true));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    // No confirmation dialog — session ends immediately.
    expect(find.byKey(const Key('stop_confirm_button')), findsNothing);
    expect(ended, isTrue);
  });
}
