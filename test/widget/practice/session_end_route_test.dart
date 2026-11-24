// ABOUTME: Widget tests for how a finished drill session leaves the screen and logs history.
// ABOUTME: A session that ends under an open sheet or dialog must close itself and log only once.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/crash/no_op_crash_report_service.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

/// Default Character Creation: 2 characters, first and return pass, 60 s each.
const _characterCreationLength = Duration(minutes: 4);

void main() {
  late InMemoryPracticeHistoryRepository history;

  Future<void> startCharacterCreation(WidgetTester tester) async {
    history = InMemoryPracticeHistoryRepository();
    await tester.pumpWidget(AppServices(
      promptRepository: InMemoryPromptRepository(),
      drillSettingsRepository: InMemoryDrillSettingsRepository(),
      practiceHistoryRepository: history,
      journalRepository: InMemoryJournalRepository(),
      appPreferencesRepository: InMemoryAppPreferencesRepository(),
      ttsService: FakeTtsService(),
      crashReportService: const NoOpCrashReportService(),
      child: const HermitProvApp(),
    ));
    await tester.pumpAndSettle();
    final card = find.text('Character Creation', skipOffstage: false);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();
    // Run to ten seconds before the end.
    await tester.pump(_characterCreationLength - const Duration(seconds: 10));
  }

  Future<void> runPastEnd(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
  }

  void expectBackOnPracticeHome() {
    expect(find.byKey(const Key('stop_end_button')), findsNothing);
    expect(find.byType(DrillSessionShell), findsNothing);
    expect(find.text('Character Creation', skipOffstage: false), findsOneWidget);
  }

  group('Finite session ending while something is open over it', () {
    testWidgets('instructions sheet open: session closes and returns home',
        (tester) async {
      await startCharacterCreation(tester);
      await tester.tap(find.byKey(const Key('session_info_button')));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);

      await runPastEnd(tester);

      expect(find.byType(BottomSheet), findsNothing);
      expectBackOnPracticeHome();
      expect(await history.getSessions(), hasLength(1));
    });

    testWidgets('"Leave drill?" dialog open: session closes and returns home',
        (tester) async {
      await startCharacterCreation(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Leave drill?'), findsOneWidget);

      await runPastEnd(tester);

      expect(find.text('Leave drill?'), findsNothing);
      expectBackOnPracticeHome();
      expect(await history.getSessions(), hasLength(1));
    });
  });

  group('Configure from inside a session', () {
    testWidgets('returning from configure relaunches one fresh session',
        (tester) async {
      await startCharacterCreation(tester);
      await tester.tap(find.byKey(const Key('session_configure_button')));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // A fresh, idle session replaces the old one.
      expect(find.byKey(const Key('start_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pumpAndSettle();
      expectBackOnPracticeHome();
    });

    testWidgets('session ending while configure is open does not relaunch',
        (tester) async {
      await startCharacterCreation(tester);
      await tester.tap(find.byKey(const Key('session_configure_button')));
      await tester.pumpAndSettle();

      await runPastEnd(tester);

      expectBackOnPracticeHome();
    });
  });

  group('DrillSessionShell logs a session at most once', () {
    testWidgets('Stop after a finished session does not log it again',
        (tester) async {
      final repo = InMemoryPracticeHistoryRepository();
      final controller = DrillSessionController(segments: [
        const DrillSegment(
          id: 'only',
          type: DrillSegmentType.timed,
          duration: Duration(seconds: 40),
          label: 'Only',
        ),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: DrillSessionShell(
          controller: controller,
          // Leaving the session on screen, as the old pop() did when a
          // dialog was on top.
          onSessionEnd: () {},
          historyRepository: repo,
          drillId: DrillId.characterCreation,
        ),
      ));
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 41));
      expect(await repo.getSessions(), hasLength(1));

      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pump();

      expect(await repo.getSessions(), hasLength(1));
    });
  });
}
