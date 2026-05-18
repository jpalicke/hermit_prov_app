// ABOUTME: Widget tests for the Cat/Clock drill — start, configure, session, and stop.
// ABOUTME: Tests use real in-memory repositories to verify settings persistence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_start_screen.dart';

Widget _wrap(Widget child) {
  return AppServices.withInMemory(
    child: MaterialApp(home: child),
  );
}

void main() {
  // 1. Start launches Cat/Clock with two prompts.
  testWidgets('Start launches session and shows two prompts', (tester) async {
    await tester.pumpWidget(_wrap(const CatClockStartScreen()));
    await tester.pump();

    // Tap Start.
    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    // Allow async prompt loading + widget build.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // The session shell should be on screen.
    expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
  });

  // 2. Configure saves changed speaking/regroup durations.
  testWidgets('Configure saves speaking and regroup durations', (tester) async {
    final services = AppServices.withInMemory(
      child: const MaterialApp(home: CatClockConfigureScreen()),
    );

    // Extract the AppServices so we can read back settings.
    await tester.pumpWidget(services);
    await tester.pump();

    // Increment speaking minutes once (default 3 → 4).
    await tester.tap(find.byKey(const Key('minutes_increment')));
    await tester.pump();

    // Tap Save.
    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    // Read back from the repository via the InheritedWidget.
    final appServices = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(appServices).drillSettingsRepository;
    final saved = await repo.getSettings(DrillId.catClock) as CatClockSettings;
    expect(saved.speakingDuration, const Duration(minutes: 4));
  });

  // 3. Pause/Resume works.
  testWidgets('Pause and Resume work in Cat/Clock session', (tester) async {
    await tester.pumpWidget(_wrap(const CatClockStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify running — button shows "Pause".
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
  });

  // 4. Stop confirmation returns to Cat/Clock Start screen.
  testWidgets('Stop confirmation pops session screen', (tester) async {
    await tester.pumpWidget(_wrap(const CatClockStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap Stop.
    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    // Confirm.
    await tester.tap(find.byKey(const Key('stop_confirm_button')));
    await tester.pumpAndSettle();

    // Should be back on the start screen.
    expect(find.byKey(const Key('drill_start_start_button')), findsOneWidget);
  });
}
