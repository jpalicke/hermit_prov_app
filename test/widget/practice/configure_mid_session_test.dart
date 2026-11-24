// ABOUTME: Widget tests for opening Configure from inside a running drill session.
// ABOUTME: The session must pause, fall silent, and be logged to History before it restarts with new settings.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/crash/no_op_crash_report_service.dart';
import 'package:hermit_prov_app/data/device/fake_screen_awake_service.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_configure_screen.dart';

void main() {
  late FakeTtsService tts;
  late InMemoryPracticeHistoryRepository history;
  late FakeScreenAwakeService awake;

  /// Opens a hands-free A-to-C session (it starts on its own) and lets it
  /// run for [ran] before returning.
  Future<void> runHandsFreeAtoC(WidgetTester tester, Duration ran) async {
    tts = FakeTtsService();
    history = InMemoryPracticeHistoryRepository();
    awake = FakeScreenAwakeService();
    final settings = InMemoryDrillSettingsRepository();
    await settings.saveSettings(const AtoCSettings(handsFreeModeEnabled: true));

    await tester.pumpWidget(
      AppServices(
        promptRepository: InMemoryPromptRepository(),
        drillSettingsRepository: settings,
        practiceHistoryRepository: history,
        journalRepository: InMemoryJournalRepository(),
        appPreferencesRepository: InMemoryAppPreferencesRepository(),
        ttsService: tts,
        crashReportService: const NoOpCrashReportService(),
        screenAwakeService: awake,
        child: const HermitProvApp(),
      ),
    );
    await tester.pumpAndSettle();

    final card = find.text(
      'A-to-C / Bad Idea / Initiation',
      skipOffstage: false,
    );
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    // Let the route transition finish and the hands-free session start.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      find.byKey(const Key('pause_resume_button')),
      findsOneWidget,
      reason: 'hands-free session should be running',
    );
    await tester.pump(ran);
  }

  Future<void> openConfigure(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('session_configure_button')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(AtoCConfigureScreen), findsOneWidget);
  }

  Future<void> closeConfigure(WidgetTester tester) async {
    Navigator.of(tester.element(find.byType(AtoCConfigureScreen))).pop();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the voice stops and stays quiet while Configure is open', (
    tester,
  ) async {
    await runHandsFreeAtoC(tester, const Duration(seconds: 40));
    final stopsBefore = tts.stopCount;

    await openConfigure(tester);
    expect(
      tts.stopCount,
      greaterThan(stopsBefore),
      reason: 'speech in progress should be cut off',
    );
    final spokenBefore = tts.spoken.length;

    // Several 30-second reps' worth of time passes on the configure screen.
    await tester.pump(const Duration(minutes: 2));

    expect(
      tts.spoken.length,
      spokenBefore,
      reason: 'no announcements while the user edits settings',
    );
    expect(
      awake.isAwake,
      isFalse,
      reason: 'the screen may sleep while the drill is paused',
    );

    await closeConfigure(tester);
  });

  testWidgets(
    'the session is logged with only its practice time when it restarts '
    'with new settings',
    (tester) async {
      await runHandsFreeAtoC(tester, const Duration(seconds: 40));

      await openConfigure(tester);
      await tester.pump(const Duration(minutes: 2));
      await closeConfigure(tester);

      // The drill has restarted with the saved settings.
      expect(find.byType(AtoCConfigureScreen), findsNothing);
      expect(find.byKey(const Key('stop_end_button')), findsOneWidget);

      final sessions = await history.getSessions();
      expect(sessions, hasLength(1));
      expect(sessions.single.drillId, DrillId.atoC);
      // Time spent on the configure screen is not practice time.
      expect(sessions.single.duration.inSeconds, inInclusiveRange(40, 41));
    },
  );

  testWidgets('a session already logged by Stop is not logged again',
      (tester) async {
    await runHandsFreeAtoC(tester, const Duration(seconds: 40));
    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pump();
    expect(await history.getSessions(), hasLength(1));

    await openConfigure(tester);
    await closeConfigure(tester);

    expect(await history.getSessions(), hasLength(1));
  });

  testWidgets('leaving the drill mid-session logs it exactly once',
      (tester) async {
    await runHandsFreeAtoC(tester, const Duration(seconds: 40));

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.tap(find.text('Leave'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('stop_end_button')), findsNothing,
        reason: 'back on the Practice home screen');
    expect(await history.getSessions(), hasLength(1));
  });

  testWidgets('a session under 30 seconds is still not logged', (tester) async {
    await runHandsFreeAtoC(tester, const Duration(seconds: 10));

    await openConfigure(tester);
    await closeConfigure(tester);

    expect(await history.getSessions(), isEmpty);
  });
}
