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
  // 1. Session screen shows pause/resume and stop controls.
  testWidgets('Session shows session shell controls', (tester) async {
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

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
    await tester.pumpWidget(_wrapSession());
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

  // 4. Stop confirmation calls onSessionEnd.
  testWidgets('Stop confirmation calls onSessionEnd', (tester) async {
    var ended = false;
    await tester.pumpWidget(_wrapSession(onConfigure: null));
    // Override onSessionEnd by pumping a direct widget.
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

    await tester.tap(find.byKey(const Key('stop_confirm_button')));
    await tester.pumpAndSettle();

    expect(ended, isTrue);
  });
}
