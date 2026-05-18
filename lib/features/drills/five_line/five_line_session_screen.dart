// ABOUTME: Session screen for the Five Line Game drill — manual tap or auto-advance modes.
// ABOUTME: No line/structure labels are shown; only the prompt and timer when auto-advance is on.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

/// Session screen for Five Line Game.
///
/// Manual mode (autoAdvance = false):
///   - Shows prompt + "New Prompt" button; no timer.
///
/// Auto-advance mode (autoAdvance = true):
///   - Uses a DrillSessionController + DrillSessionShell for timed reps.
///   - Pause/Resume work; Stop/End confirmation works.
class FiveLineSessionScreen extends StatefulWidget {
  const FiveLineSessionScreen({
    super.key,
    required this.settings,
    required this.onSessionEnd,
    this.promptRepository,
  });

  final FiveLineGameSettings settings;
  final VoidCallback onSessionEnd;

  /// Injected prompt repository. When null, AppServices.of(context) is used
  /// (must be called outside initState via didChangeDependencies).
  final PromptRepository? promptRepository;

  @override
  State<FiveLineSessionScreen> createState() => _FiveLineSessionScreenState();
}

class _FiveLineSessionScreenState extends State<FiveLineSessionScreen> {
  String? _prompt;
  bool _loading = false;
  bool _initialized = false;

  // Auto-advance only:
  DrillSessionController? _controller;
  Timer? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadPrompt();
      if (widget.settings.autoAdvance) {
        _initController();
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadPrompt() async {
    setState(() => _loading = true);
    final repo =
        widget.promptRepository ?? AppServices.of(context).promptRepository;
    final picker = PromptPicker(repo);
    final p = await picker.pickFromCategories(widget.settings.promptCategories);
    if (mounted) {
      setState(() {
        _prompt = p;
        _loading = false;
      });
    }
  }

  void _initController() {
    final interval = widget.settings.autoAdvanceInterval ??
        FiveLineGameSettings.allowedAutoAdvanceIntervals.first;
    final seg = DrillSegment(
      id: 'five_line_0',
      type: DrillSegmentType.timed,
      duration: interval,
    );
    _controller = DrillSessionController(
      segments: [seg],
      loops: true,
      tickDuration: const Duration(seconds: 1),
    );
    _controller!.start();
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _controller == null) return;
      setState(() => _controller!.tick());
      // When the loop rolls over, load a new prompt.
      if (_controller!.state.loops > (_lastLoopCount ?? -1)) {
        _lastLoopCount = _controller!.state.loops;
        _loadPrompt();
      }
    });
  }

  int? _lastLoopCount;

  Future<void> _handleStop() async {
    _ticker?.cancel();
    _controller?.pause();
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
      _controller?.stop();
      widget.onSessionEnd();
    } else {
      // Resume.
      _controller?.resume();
      _startTicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.settings.autoAdvance) {
      return _buildAutoAdvanceMode();
    }
    return _buildManualMode();
  }

  // ── Manual mode ─────────────────────────────────────────────────────────────

  Widget _buildManualMode() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Five Line Game Drill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(
                        _prompt ?? '—',
                        key: const Key('five_line_prompt'),
                        textAlign: TextAlign.center,
                        style: tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
              ),
            ),
            FilledButton(
              key: const Key('new_prompt_button'),
              onPressed: _loadPrompt,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text('New Prompt'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('stop_end_button'),
              onPressed: _handleStop,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: cs.error),
                foregroundColor: cs.error,
              ),
              child: const Text('Stop / End'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Auto-advance mode ────────────────────────────────────────────────────────

  Widget _buildAutoAdvanceMode() {
    final ctrl = _controller;
    if (ctrl == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DrillSessionShell(
      key: const Key('five_line_auto_shell'),
      controller: ctrl,
      onSessionEnd: widget.onSessionEnd,
      contentBuilder: (context, state) {
        if (_loading || _prompt == null) return const SizedBox.shrink();
        return Text(
          _prompt!,
          key: const Key('five_line_prompt'),
          textAlign: TextAlign.center,
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        );
      },
    );
  }
}
