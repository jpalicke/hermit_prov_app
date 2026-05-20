// ABOUTME: Standalone timer tool screen with Simple and Interval modes.
// ABOUTME: Toggles between a config view (pick durations) and a running view (countdown ring + controls).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';

/// Which timer mode the user has selected.
enum _TimerMode { simple, interval }

/// Standalone Timer screen reachable from the Tools screen.
///
/// Displays a config view when idle (mode + duration pickers, Start button)
/// and transitions inline to a running view (countdown ring, Pause/Resume,
/// Stop) without any navigation push.  Uses [DrillSessionController] for
/// state-machine logic and a [Timer.periodic] for ticking.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // ── Config state ──────────────────────────────────────────────────────────

  _TimerMode _mode = _TimerMode.simple;

  /// Simple mode: single countdown duration (in minutes).
  int _simpleMins = 5;

  /// Interval mode: work duration (minutes).
  int _workMins = 3;

  /// Interval mode: rest duration (minutes).
  int _restMins = 1;

  // ── Running state ─────────────────────────────────────────────────────────

  /// Non-null while the timer is in the running view.
  DrillSessionController? _controller;

  Timer? _ticker;

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _isRunningView => _controller != null;

  List<DrillSegment> _buildSegments() {
    if (_mode == _TimerMode.simple) {
      return [
        DrillSegment(
          id: 'work',
          type: DrillSegmentType.timed,
          duration: Duration(minutes: _simpleMins),
        ),
      ];
    } else {
      return [
        DrillSegment(
          id: 'work',
          type: DrillSegmentType.speaking,
          duration: Duration(minutes: _workMins),
          label: 'Work',
        ),
        DrillSegment(
          id: 'rest',
          type: DrillSegmentType.regroup,
          duration: Duration(minutes: _restMins),
          label: 'Rest',
        ),
      ];
    }
  }

  void _handleStart() {
    final controller = DrillSessionController(
      segments: _buildSegments(),
      loops: _mode == _TimerMode.interval,
    );
    controller.start();
    setState(() {
      _controller = controller;
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final ctrl = _controller;
      if (ctrl == null) return;
      setState(() {
        ctrl.tick();
      });
    });
  }

  void _handlePauseResume() {
    final ctrl = _controller;
    if (ctrl == null) return;
    setState(() {
      if (ctrl.state.isRunning) {
        ctrl.pause();
      } else if (ctrl.state.isPaused) {
        ctrl.resume();
      }
    });
  }

  void _handleStop() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _controller = null;
    });
  }

  void _handleRestart() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _controller = null;
    });
    // Re-enter running view immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleStart();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: _isRunningView ? _buildRunningView(context) : _buildConfigView(context),
    );
  }

  // ── Config view ───────────────────────────────────────────────────────────

  Widget _buildConfigView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode selector
          Text('Mode', style: tt.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<_TimerMode>(
            segments: const [
              ButtonSegment(
                value: _TimerMode.simple,
                label: Text('Simple', key: Key('timer_mode_simple')),
                icon: Icon(Icons.timer_outlined),
              ),
              ButtonSegment(
                value: _TimerMode.interval,
                label: Text('Interval', key: Key('timer_mode_interval')),
                icon: Icon(Icons.repeat),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selected) {
              setState(() {
                _mode = selected.first;
              });
            },
          ),
          const SizedBox(height: 32),

          // Duration pickers
          if (_mode == _TimerMode.simple) ...[
            _DurationPicker(
              label: 'Duration',
              minutes: _simpleMins,
              onChanged: (v) => setState(() => _simpleMins = v),
            ),
          ] else ...[
            _DurationPicker(
              label: 'Work',
              minutes: _workMins,
              onChanged: (v) => setState(() => _workMins = v),
            ),
            const SizedBox(height: 24),
            _DurationPicker(
              label: 'Rest',
              minutes: _restMins,
              onChanged: (v) => setState(() => _restMins = v),
            ),
          ],

          const SizedBox(height: 40),

          FilledButton.icon(
            key: const Key('timer_start_button'),
            onPressed: _handleStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),

          // Mode hint
          const SizedBox(height: 16),
          Text(
            _mode == _TimerMode.simple
                ? 'Counts down once and stops.'
                : 'Alternates Work and Rest cycles indefinitely.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Running view ──────────────────────────────────────────────────────────

  Widget _buildRunningView(BuildContext context) {
    final ctrl = _controller!;
    final state = ctrl.state;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final remainingSecs = state.segmentRemaining.inSeconds;
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;
    final timeText =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final isCompleted = state.isCompleted;
    final isPaused = state.isPaused;

    // For interval mode: show segment label and cycle number.
    final segmentLabel = state.currentSegment?.label;
    final cycleNumber = state.loops + 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cycle info for interval mode
            if (_mode == _TimerMode.interval && segmentLabel != null)
              Center(
                child: Text(
                  '$segmentLabel  •  Cycle $cycleNumber',
                  style: tt.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_mode == _TimerMode.interval) const SizedBox(height: 8),

            // Progress ring + countdown
            Expanded(
              flex: 3,
              child: Center(
                child: Semantics(
                  liveRegion: true,
                  label: isCompleted
                      ? 'Timer done'
                      : isPaused
                          ? 'Timer paused at $timeText'
                          : 'Timer running: $timeText remaining',
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: isCompleted ? 1.0 : state.segmentProgress,
                          strokeWidth: 10,
                          backgroundColor: cs.surfaceContainerHighest,
                          color: isCompleted ? cs.tertiary : cs.primary,
                        ),
                      ),
                      ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCompleted)
                              Text(
                                'Done',
                                style: tt.headlineMedium?.copyWith(
                                  color: cs.tertiary,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            else
                              Text(
                                timeText,
                                key: const Key('timer_countdown'),
                                style: tt.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            if (isPaused)
                              Text(
                                'PAUSED',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.outline,
                                  letterSpacing: 2,
                                ),
                              ),
                            if (state.isIdle)
                              Text(
                                'READY',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.outline,
                                  letterSpacing: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Controls
            const SizedBox(height: 16),
            if (isCompleted) ...[
              FilledButton.icon(
                onPressed: _handleRestart,
                icon: const Icon(Icons.replay),
                label: const Text('Restart'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else ...[
              FilledButton.icon(
                key: const Key('timer_pause_resume_button'),
                onPressed: _handlePauseResume,
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(isPaused ? 'Resume' : 'Pause'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('timer_stop_button'),
              onPressed: _handleStop,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(color: cs.error),
                foregroundColor: cs.error,
              ),
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Duration picker widget ────────────────────────────────────────────────────

/// A +/- control for picking a minute duration in the range 1 to 60.
class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.label,
    required this.minutes,
    required this.onChanged,
  });

  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  String _formatMmSs(int mins) {
    final m = mins.toString().padLeft(2, '0');
    return '$m:00';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: tt.titleMedium,
          ),
        ),
        Semantics(
          label: 'Decrease $label by 1 minute',
          button: true,
          child: ExcludeSemantics(
            child: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: cs.primary,
              tooltip: 'Decrease $label by 1 minute',
              onPressed: minutes <= 1
                  ? null
                  : () => onChanged(minutes - 1),
            ),
          ),
        ),
        Semantics(
          label: '$label: $minutes ${minutes == 1 ? 'minute' : 'minutes'}',
          child: SizedBox(
            width: 72,
            child: ExcludeSemantics(
              child: Text(
                _formatMmSs(minutes),
                textAlign: TextAlign.center,
                style: tt.titleLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Semantics(
          label: 'Increase $label by 1 minute',
          button: true,
          child: ExcludeSemantics(
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: cs.primary,
              tooltip: 'Increase $label by 1 minute',
              onPressed: minutes >= 60
                  ? null
                  : () => onChanged(minutes + 1),
            ),
          ),
        ),
      ],
    );
  }
}
