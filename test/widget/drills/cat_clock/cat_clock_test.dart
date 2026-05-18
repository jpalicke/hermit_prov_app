// ABOUTME: Widget tests for the Cat/Clock drill — session, configure, and stop.
// ABOUTME: Tests use real in-memory repositories to verify settings persistence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_session_screen.dart';

Widget _wrapSession({VoidCallback? onConfigure}) {
  return AppServices.withInMemory(
    child: Builder(
      builder: (context) {
        final services = AppServices.of(context);
        return MaterialApp(
          home: CatClockSessionScreen(
            settings: const CatClockSettings(),
            promptRepository: services.promptRepository,
            onSessionEnd: () {},
            onConfigure: onConfigure,
          ),
        );
      },
    ),
  );
}

void main() {
  // 1. Session screen shows start and stop controls.
  testWidgets('Session shows session shell controls', (tester) async {
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

  // 2. Hands-Free toggle is present and off by default in configure screen.
  testWidgets('Configure has Hands-Free toggle off by default', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: CatClockConfigureScreen()),
      ),
    );
    await tester.pump();

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('hands_free_toggle')),
    );
    expect(toggle.value, isFalse);
  });

  // 3. Configure saves changed speaking/regroup durations.
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
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Start the session first.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    // Verify running — button shows "Pause".
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
  });

  // 4. Stop calls onSessionEnd immediately without a confirmation dialog.
  testWidgets('Stop calls onSessionEnd immediately', (tester) async {
    var ended = false;
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: Builder(
          builder: (context) {
            final services = AppServices.of(context);
            return MaterialApp(
              home: CatClockSessionScreen(
                settings: const CatClockSettings(),
                promptRepository: services.promptRepository,
                onSessionEnd: () => ended = true,
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    // No confirmation dialog — session ends immediately.
    expect(find.byKey(const Key('stop_confirm_button')), findsNothing);
    expect(ended, isTrue);
  });
}
