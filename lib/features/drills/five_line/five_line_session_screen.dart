// ABOUTME: Session screen for the Five Line Game drill — manual tap or auto-advance modes.
// ABOUTME: No line/structure labels are shown; only the prompt and timer when auto-advance is on.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/domain/tts/hands_free_announcement_policy.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

/// Session screen for Five Line Game.
///
/// Manual mode (autoAdvance = false):
///   - Shows prompt + "New Prompt" button; no timer.
///
/// Auto-advance mode (autoAdvance = true):
///   - Uses a DrillSessionController + DrillSessionShell for timed reps.
///   - DrillSessionShell manages Start/Pause/Resume/Stop; no confirmation dialog.
class FiveLineSessionScreen extends StatefulWidget {
  const FiveLineSessionScreen({
    super.key,
    required this.settings,
    required this.onSessionEnd,
    this.promptRepository,
    this.onConfigure,
    this.historyRepository,
    this.ttsService,
  });

  final FiveLineGameSettings settings;
  final VoidCallback onSessionEnd;

  /// Injected prompt repository. When null, AppServices.of(context) is used
  /// (must be called outside initState via didChangeDependencies).
  final PromptRepository? promptRepository;
  final VoidCallback? onConfigure;
  final PracticeHistoryRepository? historyRepository;

  /// When provided and [settings.handsFreeModeEnabled] is true, drives TTS
  /// announcements during the session. Null-safe: no-op when null.
  final TtsService? ttsService;

  @override
  State<FiveLineSessionScreen> createState() => _FiveLineSessionScreenState();
}

class _FiveLineSessionScreenState extends State<FiveLineSessionScreen> {
  static const _instructions =
      'A prompt appears. Perform a five-line scene out loud. When you are done, tap New Prompt '
      'to go again. No timer by default. Turn on auto-advance in configure if you want one.';
  String? _prompt;
  bool _loading = false;
  bool _initialized = false;

  // Auto-advance only:
  DrillSessionController? _controller;
  int? _lastLoopCount;
  HandsFreeAnnouncementPolicy? _policy;
  String? _lastAnnouncedSegmentId;

  bool get _handsFreeActive =>
      widget.settings.handsFreeModeEnabled && widget.ttsService != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (_handsFreeActive) {
        _policy = HandsFreeAnnouncementPolicy(widget.ttsService!);
      }
      _loadPrompt();
      if (widget.settings.autoAdvance) {
        _initController();
      }
    }
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
    // Controller stays idle — DrillSessionShell's Start button will call start().
  }

  void _handleTick(DrillSessionState state) {
    final policy = _policy;
    if (policy == null) return;
    final seg = state.currentSegment;
    if (seg == null) return;

    final paused = state.isPaused;

    if (_lastAnnouncedSegmentId != seg.id) {
      _lastAnnouncedSegmentId = seg.id;
      if (_prompt != null) {
        policy.onSegmentStart(
          seg.copyWith(promptPayload: _prompt),
          paused: paused,
        );
      } else {
        policy.onSegmentStart(seg, paused: paused);
      }
    }

    policy.onTick(seg, state.segmentRemaining, paused: paused);
  }

  void _handleStop() {
    widget.ttsService?.stop();
    widget.onSessionEnd();
  }

  void _showInstructions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(_instructions, style: tt.bodyMedium),
          ),
        );
      },
    );
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
        actions: [
          IconButton(
            key: const Key('session_info_button'),
            icon: const Icon(Icons.info_outline),
            tooltip: 'View drill instructions',
            onPressed: () => _showInstructions(context),
          ),
        ],
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
            if (widget.onConfigure != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('session_configure_button'),
                onPressed: widget.onConfigure,
                icon: const Icon(Icons.settings),
                label: const Text('Configure'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('stop_end_button'),
              onPressed: _handleStop,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
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
      onSessionEnd: _handleStop,
      onConfigure: widget.onConfigure,
      historyRepository: widget.historyRepository,
      drillId: DrillId.fiveLineGame,
      autoStart: widget.settings.handsFreeModeEnabled,
      instructions: _instructions,
      contentBuilder: (context, state) {
        // Detect loop boundary — load a new prompt when the loop counter advances.
        if (state.loops > (_lastLoopCount ?? -1)) {
          _lastLoopCount = state.loops;
          // Schedule prompt load after the current build completes.
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrompt());
        }
        _handleTick(state);
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
