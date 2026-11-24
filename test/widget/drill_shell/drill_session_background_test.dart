// ABOUTME: Widget tests for how DrillSessionShell behaves when the screen would lock or the app is backgrounded.
// ABOUTME: Covers the screen wakelock, pausing on background, and wall-clock timing without drift.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/crash/no_op_crash_report_service.dart';
import 'package:hermit_prov_app/data/device/fake_screen_awake_service.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

DrillSessionController _controller({int seconds = 300}) =>
    DrillSessionController(segments: [
      DrillSegment(
        id: 'practice',
        type: DrillSegmentType.speaking,
        duration: Duration(seconds: seconds),
      ),
    ]);

Widget _wrap(
  DrillSessionController controller,
  FakeScreenAwakeService awake, {
  VoidCallback? onSessionEnd,
}) {
  return AppServices(
    promptRepository: InMemoryPromptRepository(),
    drillSettingsRepository: InMemoryDrillSettingsRepository(),
    practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
    journalRepository: InMemoryJournalRepository(),
    appPreferencesRepository: InMemoryAppPreferencesRepository(),
    ttsService: FakeTtsService(),
    crashReportService: const NoOpCrashReportService(),
    screenAwakeService: awake,
    child: MaterialApp(
      home: DrillSessionShell(
        controller: controller,
        onSessionEnd: onSessionEnd ?? () {},
      ),
    ),
  );
}

Future<void> _background(WidgetTester tester) async {
  for (final s in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(s);
  }
  await tester.pump();
}

Future<void> _foreground(WidgetTester tester) async {
  for (final s in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(s);
  }
  await tester.pump();
}

void main() {
  group('screen wakelock', () {
    testWidgets('is held only while the session is running', (tester) async {
      final awake = FakeScreenAwakeService();
      final controller = _controller();
      await tester.pumpWidget(_wrap(controller, awake));
      expect(awake.isAwake, isFalse, reason: 'idle session');

      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();
      expect(awake.isAwake, isTrue, reason: 'running session');

      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pump();
      expect(awake.isAwake, isFalse, reason: 'paused session');

      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pump();
      expect(awake.isAwake, isTrue, reason: 'resumed session');

      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pump();
      expect(awake.isAwake, isFalse, reason: 'stopped back to idle');
    });

    testWidgets('is released when a finite session completes', (tester) async {
      final awake = FakeScreenAwakeService();
      var ended = false;
      await tester.pumpWidget(
        _wrap(_controller(seconds: 3), awake, onSessionEnd: () => ended = true),
      );
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(ended, isTrue);
      expect(awake.isAwake, isFalse);
    });

    testWidgets('is released when the shell is disposed mid-session',
        (tester) async {
      final awake = FakeScreenAwakeService();
      await tester.pumpWidget(_wrap(_controller(), awake));
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();
      expect(awake.isAwake, isTrue);

      await tester.pumpWidget(const SizedBox());
      expect(awake.isAwake, isFalse);
    });
  });

  group('app backgrounded', () {
    testWidgets('pauses a running session and keeps the time it had',
        (tester) async {
      final awake = FakeScreenAwakeService();
      final controller = _controller();
      await tester.pumpWidget(_wrap(controller, awake));
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(controller.state.sessionElapsed, const Duration(seconds: 5));

      await _background(tester);
      expect(controller.state.isPaused, isTrue);
      expect(awake.isAwake, isFalse);

      // Time passes while the app is away; the drill must not count it.
      await tester.pump(const Duration(minutes: 2));
      await _foreground(tester);
      await tester.pump(const Duration(seconds: 3));

      expect(controller.state.isPaused, isTrue);
      expect(controller.state.sessionElapsed, const Duration(seconds: 5));
      expect(find.text('04:55'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);
    });

    testWidgets('a session the user paused stays paused', (tester) async {
      final controller = _controller();
      await tester.pumpWidget(_wrap(controller, FakeScreenAwakeService()));
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pump();

      await _background(tester);
      await _foreground(tester);

      expect(controller.state.isPaused, isTrue);
    });

    testWidgets('a brief inactive state (e.g. control center) does not pause',
        (tester) async {
      final controller = _controller();
      await tester.pumpWidget(_wrap(controller, FakeScreenAwakeService()));
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 2));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(controller.state.isRunning, isTrue);
      expect(controller.state.sessionElapsed, const Duration(seconds: 2));
    });
  });

  group('timing', () {
    testWidgets('pause and resume mid-second do not lose or add time',
        (tester) async {
      final controller = _controller();
      await tester.pumpWidget(_wrap(controller, FakeScreenAwakeService()));
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();

      // Pause just before the first second, so a callback-counting timer
      // would lose the 0.9 s already run.
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pump(const Duration(milliseconds: 1200));

      // 0.9 s + 1.2 s of running time = 2 whole seconds.
      expect(controller.state.sessionElapsed, const Duration(seconds: 2));
    });
  });
}
