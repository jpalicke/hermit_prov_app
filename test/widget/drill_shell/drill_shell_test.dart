// ABOUTME: Widget tests for the reusable drill session shell.
// ABOUTME: Uses a stub drill and manual controller ticks for deterministic timer testing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Wraps a widget with AppServices and a MaterialApp for testing.
Widget _wrap(Widget child) {
  return AppServices.withInMemory(
    child: MaterialApp(home: child),
  );
}

DrillSegment _seg(String id, {int seconds = 60}) => DrillSegment(
      id: id,
      type: DrillSegmentType.speaking,
      duration: Duration(seconds: seconds),
    );

/// A manually-ticked session shell that does NOT start an internal Timer.
/// This lets widget tests drive time without fake timers.
/// Mirrors the production DrillSessionShell UX: loads idle, Start → Pause/Resume.
class _ManualSessionShell extends StatefulWidget {
  const _ManualSessionShell({
    required this.controller,
    required this.onSessionEnd,
    required this.onConfigure,
  });

  final DrillSessionController controller;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;

  @override
  State<_ManualSessionShell> createState() => _ManualSessionShellState();
}

class _ManualSessionShellState extends State<_ManualSessionShell> {
  void tick() {
    setState(() => widget.controller.tick());
  }

  void _handleStart() {
    setState(() => widget.controller.start());
  }

  void _handlePauseResume() {
    setState(() {
      if (widget.controller.state.isRunning) {
        widget.controller.pause();
      } else {
        widget.controller.resume();
      }
    });
  }

  void _handleStop() {
    widget.controller.stop();
    widget.onSessionEnd();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    final remainingSecs = state.segmentRemaining.inSeconds;
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;
    final timeText =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final isIdle = state.isIdle;
    final isPaused = state.isPaused;

    return Scaffold(
      body: Column(
        children: [
          Text(timeText, key: const Key('session_countdown_text')),
          if (isPaused) const Text('PAUSED', key: Key('paused_label')),
          if (isIdle)
            FilledButton.icon(
              key: const Key('start_button'),
              onPressed: _handleStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            )
          else
            FilledButton.icon(
              key: const Key('pause_resume_button'),
              onPressed: _handlePauseResume,
              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(isPaused ? 'Resume' : 'Pause'),
            ),
          if (widget.onConfigure != null)
            OutlinedButton.icon(
              key: const Key('session_configure_button'),
              onPressed: widget.onConfigure,
              icon: const Icon(Icons.settings),
              label: const Text('Configure'),
            ),
          OutlinedButton(
            key: const Key('stop_end_button'),
            onPressed: _handleStop,
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // 1. Configure screen shows Save button and form content.
  testWidgets('DrillConfigureScreen shows Save button and form content',
      (tester) async {
    var saved = false;
    await tester.pumpWidget(
      _wrap(
        DrillConfigureScreen(
          drillId: DrillId.catClock,
          body: const Text('Configure form content'),
          onSave: () => saved = true,
        ),
      ),
    );

    expect(find.text('Configure form content'), findsOneWidget);
    expect(find.byKey(const Key('drill_configure_save_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    expect(saved, isTrue);
  });

  // 2. Session loads idle — Start button visible, Pause/Resume not yet shown.
  testWidgets('Session loads idle with Start button', (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0')],
      loops: true,
    );

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () {},
          onConfigure: null,
        ),
      ),
    );

    expect(find.byKey(const Key('start_button')), findsOneWidget);
    expect(find.byKey(const Key('pause_resume_button')), findsNothing);
    expect(controller.state.isIdle, isTrue);
  });

  // 3. Tapping Start begins the session and shows Pause button.
  testWidgets('Tapping Start begins session and shows Pause button',
      (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0')],
      loops: true,
    );

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () {},
          onConfigure: null,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    expect(find.byKey(const Key('start_button')), findsNothing);
    expect(find.text('Pause'), findsOneWidget);
    expect(controller.state.isRunning, isTrue);
  });

  // 4. Pause changes to Resume and freezes displayed timer.
  testWidgets('Pause changes button to Resume and freezes timer',
      (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0')],
      loops: true,
    );
    late _ManualSessionShellState shellState;

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () {},
          onConfigure: null,
        ),
      ),
    );

    shellState = tester.state(find.byType(_ManualSessionShell));

    // Start the session first.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    // Advance a few ticks.
    shellState
      ..tick()
      ..tick();
    await tester.pump();

    // Timer should be running — button shows "Pause".
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);
    expect(find.byKey(const Key('paused_label')), findsOneWidget);

    final frozenTime =
        tester.widget<Text>(find.byKey(const Key('session_countdown_text'))).data;

    // Tick while paused — timer display should not change.
    shellState
      ..tick()
      ..tick();
    await tester.pump();

    expect(
        tester
            .widget<Text>(find.byKey(const Key('session_countdown_text')))
            .data,
        frozenTime);
  });

  // 5. Stop button ends session immediately without a confirmation dialog.
  testWidgets('Stop button ends session immediately without dialog',
      (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0')],
      loops: true,
    );
    var ended = false;

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () => ended = true,
          onConfigure: null,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    // No confirmation dialog should appear.
    expect(find.byKey(const Key('stop_confirm_dialog')), findsNothing);
    expect(ended, isTrue);
    expect(controller.state.isStopped, isTrue);
  });

  // 6. DrillSessionShell shows gear icon always when onConfigure is provided.
  testWidgets(
      'DrillSessionShell shows configure button always when onConfigure provided',
      (tester) async {
    var configureOpened = false;
    final controller = DrillSessionController(
      segments: [_seg('s0')],
      loops: true,
    );

    await tester.pumpWidget(
      _wrap(
        DrillSessionShell(
          controller: controller,
          onSessionEnd: () {},
          onConfigure: () => configureOpened = true,
        ),
      ),
    );
    await tester.pump();

    // Gear icon visible in idle state (before start).
    expect(find.byKey(const Key('session_configure_button')), findsOneWidget);

    // Tap Start.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    // Gear icon still visible while running.
    expect(find.byKey(const Key('session_configure_button')), findsOneWidget);

    // Pause.
    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    // Gear icon still visible when paused.
    expect(find.byKey(const Key('session_configure_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('session_configure_button')));
    await tester.pump();

    expect(configureOpened, isTrue);
  });

  // 7. DrillSessionShell does NOT show gear icon when onConfigure is null.
  testWidgets(
      'DrillSessionShell does not show configure button when onConfigure is null',
      (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0')],
      loops: true,
    );

    await tester.pumpWidget(
      _wrap(
        DrillSessionShell(
          controller: controller,
          onSessionEnd: () {},
          // No onConfigure provided.
        ),
      ),
    );
    await tester.pump();

    // Gear icon must never appear.
    expect(find.byKey(const Key('session_configure_button')), findsNothing);

    // Tap Start and verify still no gear icon.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    expect(find.byKey(const Key('session_configure_button')), findsNothing);
  });
}
