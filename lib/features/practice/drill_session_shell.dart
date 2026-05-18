// ABOUTME: Reusable active drill session UI shell with countdown, progress ring, and controls.
// ABOUTME: Hosts a DrillSessionController and a real periodic timer; drives Pause/Resume/Stop.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';

/// Reusable active session screen.
///
/// The caller provides a [controller] that has already been configured with
/// the correct segment list.  The shell starts an internal 1-second periodic
/// Timer that calls [controller.tick] and rebuilds via [setState].
///
/// [onSessionEnd] — called after the user confirms Stop OR when a finite
///                  session completes naturally.
/// [contentBuilder] — builds the drill-specific content shown inside the
///                    session card (e.g. prompt text, character labels, etc.).
class DrillSessionShell extends StatefulWidget {
  const DrillSessionShell({
    super.key,
    required this.controller,
    required this.onSessionEnd,
    this.contentBuilder,
  });

  final DrillSessionController controller;
  final VoidCallback onSessionEnd;
  final Widget Function(BuildContext context, DrillSessionState state)?
      contentBuilder;

  @override
  State<DrillSessionShell> createState() => _DrillSessionShellState();
}

class _DrillSessionShellState extends State<DrillSessionShell> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    widget.controller.start();
    _startTicker();
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
        widget.onSessionEnd();
      }
    });
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

  Future<void> _handleStop() async {
    widget.controller.pause();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
      _ticker?.cancel();
      widget.controller.stop();
      widget.onSessionEnd();
    } else {
      // User cancelled — resume.
      setState(() => widget.controller.resume());
    }
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

    final isPaused = state.isPaused;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Circular progress + countdown ───────────────────────────
              Expanded(
                flex: 3,
                child: Center(
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // ── Drill-specific content ───────────────────────────────────
              Expanded(
                flex: 2,
                child: Center(
                  child: widget.contentBuilder != null
                      ? widget.contentBuilder!(context, state)
                      : const SizedBox.shrink(),
                ),
              ),
              // ── Controls ────────────────────────────────────────────────
              const SizedBox(height: 16),
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
                child: const Text('Stop / End'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
