// ABOUTME: Reusable active drill session UI shell with countdown, progress ring, and controls.
// ABOUTME: Hosts a DrillSessionController and a real periodic timer; drives Start/Pause/Resume/Stop.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

/// Reusable active session screen.
///
/// The caller provides a [controller] that has already been configured with
/// the correct segment list.  The shell manages an internal 1-second periodic
/// Timer that calls [controller.tick] and rebuilds via [setState].
///
/// The session loads with the timer stopped.  A Start button is shown first;
/// after starting it becomes a Pause / Resume toggle.  A separate Stop button
/// ends the session immediately without any confirmation dialog.
///
/// [onSessionEnd] — called when Stop is tapped or a finite session completes.
/// [onConfigure] — optional callback invoked when the user taps the gear icon.
///                 When null, no gear icon is shown.
/// [contentBuilder] — builds the drill-specific content shown inside the
///                    session card (e.g. prompt text, character labels, etc.).
/// [autoStart] — when true, [_handleStart] is called automatically after the
///               first frame via [WidgetsBinding.instance.addPostFrameCallback].
/// [instructions] — when provided, shows an info icon button in the top-right
///                  of the body that opens a bottom sheet with the instructions.
/// [ringLabelBuilder] — optional callback returning a label to display inside
///                      the progress ring above the countdown text.
/// [historyRepository] — when provided together with [drillId], sessions lasting
///                       at least 30 seconds are silently logged on stop or auto-complete.
/// [drillId] — the drill being practiced; required for logging.
class DrillSessionShell extends StatefulWidget {
  const DrillSessionShell({
    super.key,
    required this.controller,
    required this.onSessionEnd,
    this.onConfigure,
    this.contentBuilder,
    this.autoStart = false,
    this.instructions,
    this.ringLabelBuilder,
    this.historyRepository,
    this.drillId,
  });

  final DrillSessionController controller;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;
  final Widget Function(BuildContext context, DrillSessionState state)?
      contentBuilder;
  final bool autoStart;
  final String? instructions;
  final String? Function(DrillSessionState)? ringLabelBuilder;

  /// When provided together with [drillId], sessions lasting at least 30 seconds
  /// are silently logged on stop or auto-complete.
  final PracticeHistoryRepository? historyRepository;

  /// The drill being practiced. Required for logging; ignored when [historyRepository] is null.
  final DrillId? drillId;

  @override
  State<DrillSessionShell> createState() => _DrillSessionShellState();
}

class _DrillSessionShellState extends State<DrillSessionShell> {
  Timer? _ticker;

  /// Set when the user taps Start; used to compute session duration for logging.
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleStart();
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        widget.controller.tick();
      });
      // Auto-end when a finite session completes.
      if (widget.controller.state.isCompleted) {
        _ticker?.cancel();
        _maybeLogSession();
        widget.onSessionEnd();
      }
    });
  }

  void _handleStart() {
    _startedAt = DateTime.now();
    setState(() {
      widget.controller.start();
    });
    _startTicker();
  }

  void _handlePauseResume() {
    setState(() {
      if (widget.controller.state.isRunning) {
        widget.controller.pause();
      } else if (widget.controller.state.isPaused) {
        widget.controller.resume();
      }
    });
  }

  void _handleStop() {
    _ticker?.cancel();
    widget.controller.stop();
    _maybeLogSession();
    widget.onSessionEnd();
  }

  /// Silently logs the session when conditions are met.
  ///
  /// Conditions: historyRepository and drillId are set, the session was
  /// started, and elapsed time is at least 30 seconds.
  void _maybeLogSession() {
    final repo = widget.historyRepository;
    final drillId = widget.drillId;
    final startedAt = _startedAt;
    if (repo == null || drillId == null || startedAt == null) return;

    final elapsed = widget.controller.state.sessionElapsed;
    if (elapsed.inSeconds < 30) return;

    final session = PracticeSession(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      drillId: drillId,
      startedAt: startedAt,
      duration: elapsed,
      loggedAt: DateTime.now(),
    );
    // Fire-and-forget: logging is silent, errors are not surfaced to the user.
    repo.addSession(session);
  }

  void _showInstructions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(
              widget.instructions!,
              style: tt.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final remainingSecs = state.segmentRemaining.inSeconds;
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;
    final timeText =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final isIdle = state.isIdle;
    final isPaused = state.isPaused;

    final ringLabel = widget.ringLabelBuilder?.call(state);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Info button row ─────────────────────────────────────────────
              if (widget.instructions != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      key: const Key('session_info_button'),
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'View drill instructions',
                      onPressed: () => _showInstructions(context),
                    ),
                  ],
                ),
              // ── Circular progress + countdown ───────────────────────────
              Expanded(
                flex: 3,
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    label: isIdle
                        ? 'Timer ready. $timeText'
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
                            key: const Key('session_progress_ring'),
                            value: state.segmentProgress,
                            strokeWidth: 10,
                            backgroundColor:
                                cs.surfaceContainerHighest,
                            color: cs.primary,
                          ),
                        ),
                        ExcludeSemantics(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (ringLabel != null)
                                Text(
                                  ringLabel,
                                  key: const Key('session_ring_label'),
                                  textAlign: TextAlign.center,
                                  style: tt.labelLarge?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              Text(
                                timeText,
                                key: const Key('session_countdown_text'),
                                style: tt.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
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
                              if (isIdle)
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
              // ── Drill-specific content ───────────────────────────────────
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Center(
                    child: widget.contentBuilder != null
                        ? widget.contentBuilder!(context, state)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              // ── Controls ────────────────────────────────────────────────
              const SizedBox(height: 16),
              if (isIdle)
                FilledButton.icon(
                  key: const Key('start_button'),
                  onPressed: _handleStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                FilledButton.icon(
                  key: const Key('pause_resume_button'),
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
              if (widget.onConfigure != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('session_configure_button'),
                  onPressed: widget.onConfigure,
                  icon: const Icon(Icons.settings),
                  label: const Text('Configure'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('stop_end_button'),
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
      ),
    );
  }
}
