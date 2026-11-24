// ABOUTME: Reusable active drill session UI shell with countdown, progress ring, and controls.
// ABOUTME: Drives Start/Pause/Resume/Stop from wall-clock time, keeps the screen awake, pauses when backgrounded.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/device/screen_awake_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/session_clock.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';

/// Reusable active session screen.
///
/// The caller provides a [controller] that has already been configured with
/// the correct segment list.  The shell measures running time with a
/// [SessionClock] and, on a short periodic Timer, calls [controller.tick] once
/// for every whole tick of real time that has passed, so late timer callbacks
/// and pause/resume never make the drill clock drift.
///
/// While the session is running the shell keeps the screen on through the
/// [ScreenAwakeService] in [AppServices] (when there is one), because
/// hands-free practice happens without touching the phone.  If the app is
/// hidden or backgrounded anyway, a running session is paused so it can be
/// resumed exactly where it was.
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
    required this.controller,
    required this.onSessionEnd,
    super.key,
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

class _DrillSessionShellState extends State<DrillSessionShell>
    with WidgetsBindingObserver {
  /// How often the shell checks the clock.  Shorter than a tick so the
  /// countdown changes close to each real second.
  static const _pollInterval = Duration(milliseconds: 250);

  Timer? _ticker;

  /// Running time of the current session, excluding paused time.
  final SessionClock _clock = SessionClock();

  /// How many controller ticks have been applied for [_clock]'s time so far.
  int _ticksApplied = 0;

  ScreenAwakeService? _screenAwake;
  bool _keepingAwake = false;

  /// Set when the user taps Start; used to compute session duration for logging.
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleStart();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenAwake = context
        .getInheritedWidgetOfExactType<AppServices>()
        ?.screenAwakeService;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _setKeepAwake(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The OS suspends a hidden app, which stops the timer and TTS.  Pause so
    // the user resumes where they left off instead of on a stale clock.
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (mounted && widget.controller.state.isRunning) {
        _catchUp();
        if (!mounted || !widget.controller.state.isRunning) return;
        _pause();
      }
    }
  }

  /// Holds the screen awake while the session is running, and only then.
  void _syncKeepAwake() {
    _setKeepAwake(mounted && widget.controller.state.isRunning);
  }

  void _setKeepAwake(bool keep) {
    if (keep == _keepingAwake) return;
    _keepingAwake = keep;
    final service = _screenAwake;
    if (service == null) return;
    unawaited(keep ? service.keepAwake() : service.allowSleep());
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_pollInterval, (_) => _catchUp());
  }

  /// Applies one controller tick for every whole tick of real running time
  /// that has not been applied yet.
  void _catchUp() {
    if (!mounted) return;
    final controller = widget.controller;
    if (!controller.state.isRunning) return;
    final tickMicros = controller.tickDuration.inMicroseconds;
    final due = _clock.elapsed.inMicroseconds ~/ tickMicros - _ticksApplied;
    if (due <= 0) return;
    setState(() {
      for (var i = 0; i < due && controller.state.isRunning; i++) {
        controller.tick();
        _ticksApplied++;
      }
    });
    // Auto-end when a finite session completes.
    if (controller.state.isCompleted) {
      _handleExit();
    }
  }

  void _handleStart() {
    _startedAt = DateTime.now();
    _clock
      ..reset()
      ..start();
    _ticksApplied = 0;
    setState(() {
      widget.controller.start();
    });
    _startTicker();
    _syncKeepAwake();
  }

  void _pause() {
    _clock.pause();
    setState(widget.controller.pause);
    _syncKeepAwake();
  }

  void _handlePauseResume() {
    if (widget.controller.state.isRunning) {
      _catchUp();
      if (!mounted || !widget.controller.state.isRunning) return;
      _pause();
    } else if (widget.controller.state.isPaused) {
      _clock.start();
      setState(widget.controller.resume);
      _syncKeepAwake();
    }
  }

  // Stops the timer and returns to idle — stays in the drill.
  void _handleResetToIdle() {
    _ticker?.cancel();
    _ticker = null;
    _clock.reset();
    _ticksApplied = 0;
    _maybeLogSession();
    setState(() {
      widget.controller.reset();
    });
    _startedAt = null;
    _syncKeepAwake();
  }

  // Exits the drill entirely — called by the Exit button and natural completion.
  void _handleExit() {
    _ticker?.cancel();
    _clock.pause();
    _maybeLogSession();
    widget.controller.stop();
    _setKeepAwake(false);
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
    // A session is logged once, however many ways it is later stopped.
    _startedAt = null;
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final state = widget.controller.state;
    if (!state.isRunning && !state.isPaused) {
      _handleExit();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave drill?'),
        content: const Text(
          'Your session is still in progress. Leave anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) {
      _handleExit();
    }
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
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
                onPressed: isIdle ? _handleExit : _handleResetToIdle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: cs.error),
                  foregroundColor: cs.error,
                ),
                child: Text(isIdle ? 'Exit' : 'Stop'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
