// ABOUTME: Widget tests for the reusable drill session shell.
// ABOUTME: Uses a stub drill and manual controller ticks for deterministic timer testing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/features/practice/drill_configure_screen.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';

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
    required this.onConfigure,
  });

  final DrillSessionController controller;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;

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
          if (isPaused && widget.onConfigure != null)
            OutlinedButton.icon(
              key: const Key('session_configure_button'),
              onPressed: widget.onConfigure,
              icon: const Icon(Icons.settings),
              label: const Text('Configure'),
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

  // 2. Pause changes to Resume and freezes displayed timer.
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
          onConfigure: null,
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

  // 3. Stop/End shows confirmation dialog.
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
          onConfigure: null,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('stop_confirm_dialog')), findsOneWidget);
    expect(find.byKey(const Key('stop_confirm_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_cancel_button')), findsOneWidget);
  });

  // 4. Confirming Stop calls onSessionEnd callback.
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
          onConfigure: null,
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

  // 5. DrillSessionShell shows gear icon when paused and onConfigure is provided.
  testWidgets(
      'DrillSessionShell shows configure button when paused with onConfigure',
      (tester) async {
    var configureOpened = false;
    final controller = DrillSessionController(
      segments: [_seg('s0', seconds: 60)],
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

    // Gear icon not visible while running.
    expect(find.byKey(const Key('session_configure_button')), findsNothing);

    // Pause.
    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    // Gear icon appears when paused.
    expect(find.byKey(const Key('session_configure_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('session_configure_button')));
    await tester.pump();

    expect(configureOpened, isTrue);
  });

  // 6. DrillSessionShell does NOT show gear icon when onConfigure is null.
  testWidgets(
      'DrillSessionShell does not show configure button when onConfigure is null',
      (tester) async {
    final controller = DrillSessionController(
      segments: [_seg('s0', seconds: 60)],
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

    // Pause.
    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    // Gear icon must not appear.
    expect(find.byKey(const Key('session_configure_button')), findsNothing);
  });
}
