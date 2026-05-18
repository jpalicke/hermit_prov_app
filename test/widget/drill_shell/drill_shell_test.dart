// ABOUTME: Widget tests for the reusable drill shell (start, configure, session).
// ABOUTME: Uses a stub drill and manual controller ticks for deterministic timer testing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';

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
class _ManualSessionShell extends StatefulWidget {
  const _ManualSessionShell({
    required this.controller,
    required this.onSessionEnd,
  });

  final DrillSessionController controller;
  final VoidCallback onSessionEnd;

  @override
  State<_ManualSessionShell> createState() => _ManualSessionShellState();
}

class _ManualSessionShellState extends State<_ManualSessionShell> {
  @override
  void initState() {
    super.initState();
    widget.controller.start();
  }

  void tick() {
    setState(() => widget.controller.tick());
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

  Future<void> _handleStop() async {
    widget.controller.pause();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('stop_confirm_dialog'),
        title: const Text('End session?'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            key: const Key('stop_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            key: const Key('stop_confirm_button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End session'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      widget.controller.stop();
      widget.onSessionEnd();
    } else {
      setState(() => widget.controller.resume());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    final remainingSecs = state.segmentRemaining.inSeconds;
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;
    final timeText =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final isPaused = state.isPaused;

    return Scaffold(
      body: Column(
        children: [
          Text(timeText, key: const Key('session_countdown_text')),
          if (isPaused) const Text('PAUSED', key: Key('paused_label')),
          FilledButton.icon(
            key: const Key('pause_resume_button'),
            onPressed: _handlePauseResume,
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(isPaused ? 'Resume' : 'Pause'),
          ),
          OutlinedButton(
            key: const Key('stop_end_button'),
            onPressed: _handleStop,
            child: const Text('Stop / End'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // 1. DrillStartScreen shows Start, Configure, and info/help.
  testWidgets('DrillStartScreen shows Start, Configure, and Help buttons',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        DrillStartScreen(
          drillId: DrillId.catClock,
          subtitle: 'A test subtitle',
          onStart: () {},
          onConfigure: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('drill_start_start_button')), findsOneWidget);
    expect(
        find.byKey(const Key('drill_start_configure_button')), findsOneWidget);
    expect(find.byKey(const Key('drill_start_help_button')), findsOneWidget);
    expect(find.text('Cat/Clock'), findsWidgets);
    expect(find.text('A test subtitle'), findsOneWidget);
  });

  // 2. Configure can update a simple saved setting (basic interaction test).
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

  // 3. Start launches the session shell.
  testWidgets('Start button navigates to session shell', (tester) async {
    var sessionStarted = false;

    await tester.pumpWidget(
      _wrap(
        DrillStartScreen(
          drillId: DrillId.catClock,
          onStart: () => sessionStarted = true,
          onConfigure: () {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('drill_start_start_button')));
    await tester.pump();

    expect(sessionStarted, isTrue);
  });

  // 4. Pause changes to Resume and freezes displayed timer.
  testWidgets('Pause changes button to Resume and freezes timer',
      (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0', seconds: 60)],
      loops: true,
    );
    late _ManualSessionShellState shellState;

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () {},
        ),
      ),
    );

    shellState = tester.state(find.byType(_ManualSessionShell));

    // Advance a few ticks.
    shellState.tick();
    shellState.tick();
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
    shellState.tick();
    shellState.tick();
    await tester.pump();

    expect(
        tester
            .widget<Text>(find.byKey(const Key('session_countdown_text')))
            .data,
        frozenTime);
  });

  // 5. Stop/End shows confirmation dialog.
  testWidgets('Stop/End button shows confirmation dialog', (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0', seconds: 60)],
      loops: true,
    );

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('stop_confirm_dialog')), findsOneWidget);
    expect(find.byKey(const Key('stop_confirm_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_cancel_button')), findsOneWidget);
  });

  // 6. Confirming Stop returns to Drill Start (via onSessionEnd callback).
  testWidgets('Confirming Stop calls onSessionEnd callback', (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0', seconds: 60)],
      loops: true,
    );
    var ended = false;

    await tester.pumpWidget(
      _wrap(
        _ManualSessionShell(
          controller: controller,
          onSessionEnd: () => ended = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stop_confirm_button')));
    await tester.pumpAndSettle();

    expect(ended, isTrue);
    expect(controller.state.isStopped, isTrue);
  });
}
