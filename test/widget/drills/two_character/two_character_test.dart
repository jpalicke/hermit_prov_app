// ABOUTME: Widget tests for the Two-Character Scenes drill.
// ABOUTME: Verifies start → session, no character labels, configure, and stop confirmation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_start_screen.dart';

Widget _wrap(Widget child) =>
    AppServices.withInMemory(child: MaterialApp(home: child));

void main() {
  // 1. Start launches with one prompt.
  testWidgets('Start launches session shell', (tester) async {
    await tester.pumpWidget(_wrap(const TwoCharacterStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
  });

  // 2. No character speaker labels anywhere.
  testWidgets('Session screen has no character speaker labels', (tester) async {
    await tester.pumpWidget(_wrap(const TwoCharacterStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Make sure no "Character 1", "Character 2", "Speaker", etc. appear.
    expect(find.textContaining('Character 1'), findsNothing);
    expect(find.textContaining('Character 2'), findsNothing);
    expect(find.textContaining('Speaker'), findsNothing);
  });

  // 3. Configure saves timer/category settings.
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

  // 4. Stop confirmation works.
  testWidgets('Stop confirmation returns to Start screen', (tester) async {
    await tester.pumpWidget(_wrap(const TwoCharacterStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stop_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drill_start_start_button')), findsOneWidget);
  });
}
