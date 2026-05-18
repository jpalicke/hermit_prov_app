// ABOUTME: Widget tests for HistoryScreen — stats section, recent sessions, and empty state.
// ABOUTME: Uses InMemoryPracticeHistoryRepository to control session data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';
import 'package:hermit_prov_app/features/history/history_screen.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrap({
  required Widget child,
  InMemoryPracticeHistoryRepository? historyRepo,
}) {
  return AppServices.withInMemory(
    child: Builder(
      builder: (context) {
        // If a custom repo is provided, build a custom AppServices.
        if (historyRepo != null) {
          return AppServices(
            promptRepository: AppServices.of(context).promptRepository,
            drillSettingsRepository:
                AppServices.of(context).drillSettingsRepository,
            practiceHistoryRepository: historyRepo,
            journalRepository: AppServices.of(context).journalRepository,
            appPreferencesRepository:
                AppServices.of(context).appPreferencesRepository,
            ttsService: FakeTtsService(),
            child: child,
          );
        }
        return child;
      },
    ),
  );
}

PracticeSession _session({
  required String id,
  required DrillId drillId,
  DateTime? loggedAt,
  Duration duration = const Duration(minutes: 5),
}) {
  final ts = loggedAt ?? DateTime(2025, 5, 18, 12, 0);
  return PracticeSession(
    id: id,
    drillId: drillId,
    startedAt: ts.subtract(duration),
    duration: duration,
    loggedAt: ts,
  );
}

// Sets a tall viewport so all sliver content is built.
Future<void> _setTallViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('HistoryScreen', () {
    testWidgets('shows empty state message when no sessions exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(child: const HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No sessions yet'),
        findsOneWidget,
      );
    });

    testWidgets('shows stats section with Sessions label when sessions exist',
        (WidgetTester tester) async {
      await _setTallViewport(tester);
      final repo = InMemoryPracticeHistoryRepository();
      await repo.addSession(
        _session(id: '1', drillId: DrillId.catClock),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(child: const HistoryScreen(), historyRepo: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('shows Total Time stat when sessions exist',
        (WidgetTester tester) async {
      await _setTallViewport(tester);
      final repo = InMemoryPracticeHistoryRepository();
      await repo.addSession(
        _session(id: '1', drillId: DrillId.catClock),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(child: const HistoryScreen(), historyRepo: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Time'), findsOneWidget);
    });

    testWidgets('shows Recent Sessions section header when sessions exist',
        (WidgetTester tester) async {
      await _setTallViewport(tester);
      final repo = InMemoryPracticeHistoryRepository();
      await repo.addSession(
        _session(id: '1', drillId: DrillId.atoC),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(child: const HistoryScreen(), historyRepo: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent Sessions'), findsOneWidget);
    });

    testWidgets('does not show delete controls for individual sessions',
        (WidgetTester tester) async {
      await _setTallViewport(tester);
      final repo = InMemoryPracticeHistoryRepository();
      await repo.addSession(
        _session(id: '1', drillId: DrillId.catClock),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(child: const HistoryScreen(), historyRepo: repo),
        ),
      );
      await tester.pumpAndSettle();

      // No delete/dismiss icons should appear.
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('shows drill name in session list', (WidgetTester tester) async {
      await _setTallViewport(tester);
      final repo = InMemoryPracticeHistoryRepository();
      await repo.addSession(
        _session(id: '1', drillId: DrillId.twoCharacterScenes),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(child: const HistoryScreen(), historyRepo: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Two-Character Scenes'), findsWidgets);
    });
  });
}
