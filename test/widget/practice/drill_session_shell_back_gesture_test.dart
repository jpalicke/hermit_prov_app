// ABOUTME: Widget tests for DrillSessionShell back-gesture protection (PopScope).
// ABOUTME: Verifies the leave-drill confirm dialog fires when a session is active.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

DrillSessionController _makeController() {
  return DrillSessionController(segments: [
    const DrillSegment(
      id: 'practice_0',
      type: DrillSegmentType.speaking,
      duration: Duration(minutes: 5),
      label: 'Practice',
    ),
  ]);
}

Widget _wrap({
  required DrillSessionController controller,
  VoidCallback? onSessionEnd,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    home: DrillSessionShell(
      controller: controller,
      onSessionEnd: onSessionEnd ?? () {},
    ),
  );
}

void main() {
  group('DrillSessionShell back-gesture protection', () {
    testWidgets('idle state: back gesture exits without dialog',
        (WidgetTester tester) async {
      final controller = _makeController();
      bool exited = false;
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_wrap(
        controller: controller,
        onSessionEnd: () => exited = true,
        navigatorKey: navKey,
      ));
      await tester.pumpAndSettle();

      // Session is idle — back should exit immediately, no dialog.
      await navKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Leave drill?'), findsNothing);
      expect(exited, isTrue);
    });

    testWidgets('running state: back gesture shows confirm dialog',
        (WidgetTester tester) async {
      final controller = _makeController();
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_wrap(
        controller: controller,
        navigatorKey: navKey,
      ));
      await tester.pumpAndSettle();

      // Start the session.
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pumpAndSettle();

      // Trigger back gesture while running.
      await navKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Leave drill?'), findsOneWidget);
    });

    testWidgets('running state: confirming leave calls onSessionEnd',
        (WidgetTester tester) async {
      final controller = _makeController();
      bool exited = false;
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_wrap(
        controller: controller,
        onSessionEnd: () => exited = true,
        navigatorKey: navKey,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pumpAndSettle();

      await navKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      // Tap "Leave" to confirm.
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(exited, isTrue);
    });

    testWidgets('running state: cancelling leave keeps session running',
        (WidgetTester tester) async {
      final controller = _makeController();
      bool exited = false;
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_wrap(
        controller: controller,
        onSessionEnd: () => exited = true,
        navigatorKey: navKey,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pumpAndSettle();

      await navKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      // Tap "Stay" to cancel.
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();

      expect(find.text('Leave drill?'), findsNothing);
      expect(exited, isFalse);
    });

    testWidgets('paused state: back gesture shows confirm dialog',
        (WidgetTester tester) async {
      final controller = _makeController();
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_wrap(
        controller: controller,
        navigatorKey: navKey,
      ));
      await tester.pumpAndSettle();

      // Start then pause.
      await tester.tap(find.byKey(const Key('start_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pumpAndSettle();

      // Back while paused should still show dialog.
      await navKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Leave drill?'), findsOneWidget);
    });
  });
}
