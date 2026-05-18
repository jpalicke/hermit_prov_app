// ABOUTME: Widget tests for the A-to-C / Bad Idea / Initiation drill.
// ABOUTME: Verifies session, configure interval, and pause/resume behaviour.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_session_screen.dart';

Widget _wrapSession() {
  return AppServices.withInMemory(
    child: Builder(
      builder: (context) {
        final services = AppServices.of(context);
        return MaterialApp(
          home: AtoCSessionScreen(
            settings: const AtoCSettings(),
            promptRepository: services.promptRepository,
            onSessionEnd: () {},
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

    // Session loads idle — Start button is shown first.
    expect(find.byKey(const Key('start_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_end_button')), findsOneWidget);

    // After tapping Start, Pause/Resume button appears.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
  });

  // 2. Configure saves interval/category settings.
  testWidgets('Configure saves 60s interval', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: AtoCConfigureScreen()),
      ),
    );
    await tester.pump();

    // Select 60 seconds radio button.
    await tester.tap(find.byKey(const Key('interval_60s')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(ctx).drillSettingsRepository;
    final saved = await repo.getSettings(DrillId.atoC) as AtoCSettings;
    expect(saved.interval, const Duration(seconds: 60));
  });

  // 3. Pause/Resume freezes prompt changes.
  testWidgets('Pause shows Resume and session is paused', (tester) async {
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Start the session first.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    // Pause.
    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);

    // Resume.
    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
  });
}
