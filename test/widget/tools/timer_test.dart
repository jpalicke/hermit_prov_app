// ABOUTME: Widget tests for the standalone Timer tool screen.
// ABOUTME: Covers navigation from Tools, mode selection, duration controls, start/stop flow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';
import 'package:hermit_prov_app/features/tools/timer_screen.dart';

Widget _wrapWithServices(Widget child) {
  return AppServices.withInMemory(
    child: MaterialApp(home: child),
  );
}

void main() {
  group('TimerScreen', () {
    testWidgets('timer tool is reachable from Tools screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const ToolsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();

      expect(find.byType(TimerScreen), findsOneWidget);
    });

    testWidgets('config view shows simple and interval mode options',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const TimerScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('timer_mode_simple')), findsOneWidget);
      expect(find.byKey(const Key('timer_mode_interval')), findsOneWidget);
    });

    testWidgets('simple mode shows one duration control',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const TimerScreen()));
      await tester.pumpAndSettle();

      // Simple is the default mode — verify Work/Duration label is present.
      expect(find.text('Duration'), findsOneWidget);
      // Rest label must NOT be present.
      expect(find.text('Rest'), findsNothing);
    });

    testWidgets('interval mode shows work and rest duration controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const TimerScreen()));
      await tester.pumpAndSettle();

      // Switch to Interval mode.
      await tester.tap(find.byKey(const Key('timer_mode_interval')));
      await tester.pumpAndSettle();

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Rest'), findsOneWidget);
    });

    testWidgets('start button transitions to running view',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const TimerScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('timer_start_button')));
      await tester.pump(); // one frame to process state change

      expect(find.byKey(const Key('timer_countdown')), findsOneWidget);
    });

    testWidgets('stop button returns to config view',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const TimerScreen()));
      await tester.pumpAndSettle();

      // Start the timer.
      await tester.tap(find.byKey(const Key('timer_start_button')));
      await tester.pump();

      // Running view should be shown.
      expect(find.byKey(const Key('timer_countdown')), findsOneWidget);

      // Tap Stop.
      await tester.tap(find.byKey(const Key('timer_stop_button')));
      await tester.pump();

      // Config view is back — Start button visible again.
      expect(find.byKey(const Key('timer_start_button')), findsOneWidget);
    });
  });
}
