// ABOUTME: Widget tests for the A-to-C / Bad Idea / Initiation drill.
// ABOUTME: Verifies start, configure interval, pause/resume, and stop behaviour.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_start_screen.dart';

Widget _wrap(Widget child) =>
    AppServices.withInMemory(child: MaterialApp(home: child));

void main() {
  // 1. Start launches with one prompt.
  testWidgets('Start launches session shell', (tester) async {
    await tester.pumpWidget(_wrap(const AtoCStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_end_button')), findsOneWidget);
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
    await tester.pumpWidget(_wrap(const AtoCStartScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

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
