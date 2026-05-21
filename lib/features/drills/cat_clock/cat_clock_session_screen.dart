// ABOUTME: Active session screen for the Cat/Clock drill.
// ABOUTME: Builds segment sequences with live prompts and wraps the shared DrillSessionShell.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/cat_clock/cat_clock_sequence.dart';
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

class CatClockSessionScreen extends StatefulWidget {
  const CatClockSessionScreen({
    required this.settings,
    required this.promptRepository,
    required this.onSessionEnd,
    super.key,
    this.onConfigure,
    this.historyRepository,
    this.ttsService,
  });

  final CatClockSettings settings;
  final PromptRepository promptRepository;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;
  final PracticeHistoryRepository? historyRepository;

  /// When provided and [settings.handsFreeModeEnabled] is true, drives TTS
  /// announcements during the session. Null-safe: no-op when null.
  final TtsService? ttsService;

  @override
  State<CatClockSessionScreen> createState() => _CatClockSessionScreenState();
}

class _CatClockSessionScreenState extends State<CatClockSessionScreen> {
  static const _sequence = CatClockSequence();

  DrillSessionController? _controller;
  String? _prompt1;
  String? _prompt2;
  int _repIndex = 0;
  HandsFreeAnnouncementPolicy? _policy;

  // Tracks which segment TTS was last fired for to avoid re-announcing.
  String? _lastAnnouncedSegmentId;

  bool get _handsFreActive =>
      widget.settings.handsFreeModeEnabled && widget.ttsService != null;

  @override
  void initState() {
    super.initState();
    if (_handsFreActive) {
      _policy = HandsFreeAnnouncementPolicy(widget.ttsService!);
    }
    _initSession();
  }

  Future<void> _initSession() async {
    await _loadNextPrompts();
    final segs = _sequence.buildRep(
      settings: widget.settings,
      prompt1: _prompt1,
      prompt2: _prompt2,
      repIndex: _repIndex,
    );
    if (mounted) {
      setState(() {
        _controller = DrillSessionController(
          segments: segs,
          loops: true,
        );
      });
    }
  }

  Future<void> _loadNextPrompts() async {
    final picker = PromptPicker(widget.promptRepository);
    _prompt1 = await picker.pickFromCategories(widget.settings.prompt1Categories);
    _prompt2 = await picker.pickFromCategories(widget.settings.prompt2Categories);
  }

  /// Called by the session shell when a loop completes — regenerate prompts.
  void _onLoopComplete(DrillSessionState state) {
    if (state.loops > _repIndex) {
      _repIndex = state.loops;
      _regeneratePromptsForNextRep();
    }
  }

  Future<void> _regeneratePromptsNow() async {
    await _loadNextPrompts();
    if (mounted) setState(() {});
  }

  Future<void> _regeneratePromptsForNextRep() async {
    await _loadNextPrompts();
    if (!mounted || _controller == null) return;
    // Rebuild the controller's segment list for the upcoming loop.
    final newSegs = _sequence.buildRep(
      settings: widget.settings,
      prompt1: _prompt1,
      prompt2: _prompt2,
      repIndex: _repIndex,
    );
    // Update by creating a new controller that resumes from the same loop count.
    // We rebuild so the next loop has fresh prompts in the segments.
    setState(() {
      final wasRunning = _controller!.state.isRunning;
      _controller = DrillSessionController(
        segments: newSegs,
        loops: true,
        tickDuration: const Duration(seconds: 1),
      );
      if (wasRunning) _controller!.start();
    });
  }

  void _handleTick(DrillSessionState state) {
    final policy = _policy;
    if (policy == null) return;
    final seg = state.currentSegment;
    if (seg == null) return;

    final paused = state.isPaused;

    // Fire segment start announcement when we enter a new segment.
    if (_lastAnnouncedSegmentId != seg.id) {
      _lastAnnouncedSegmentId = seg.id;
      // For Cat/Clock speaking segments, speak both prompts.
      if (seg.type != DrillSegmentType.regroup &&
          _prompt1 != null &&
          _prompt2 != null) {
        policy.onSegmentStart(
          seg.copyWith(promptPayload: '$_prompt1 — $_prompt2'),
          paused: paused,
        );
      } else {
        policy.onSegmentStart(seg, paused: paused);
      }
    }

    // Timer countdown ticks.
    policy.onTick(seg, state.segmentRemaining, paused: paused);
  }

  void _handleStop() {
    widget.ttsService?.stop();
    widget.onSessionEnd();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DrillSessionShell(
      controller: ctrl,
      onSessionEnd: _handleStop,
      onConfigure: widget.onConfigure,
      historyRepository: widget.historyRepository,
      drillId: DrillId.catClock,
      autoStart: widget.settings.handsFreeModeEnabled,
      instructions:
          'Two prompts appear on screen. Connect the two words through free association, '
          'speaking out loud until the timer ends. A short regroup follows, then fresh prompts '
          'appear automatically for the next rep. Runs until you stop it.',
      contentBuilder: (context, state) {
        _handleTick(state);
        final seg = state.currentSegment;
        if (seg == null) return const SizedBox.shrink();

        if (seg.type == DrillSegmentType.regroup) {
          return _RegroupContent();
        }

        return _SpeakingContent(
          prompt1: _prompt1,
          prompt2: _prompt2,
          onStateChanged: () => _onLoopComplete(state),
          onRegenerate: _regeneratePromptsNow,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SpeakingContent extends StatelessWidget {
  const _SpeakingContent({
    required this.prompt1,
    required this.prompt2,
    required this.onStateChanged,
    required this.onRegenerate,
  });

  final String? prompt1;
  final String? prompt2;
  final VoidCallback onStateChanged;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prompt1 != null)
          Text(
            prompt1!,
            key: const Key('cat_clock_prompt1'),
            textAlign: TextAlign.center,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        if (prompt1 != null && prompt2 != null)
          const SizedBox(height: 8),
        if (prompt2 != null)
          Text(
            prompt2!,
            key: const Key('cat_clock_prompt2'),
            textAlign: TextAlign.center,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.secondary,
            ),
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          key: const Key('cat_clock_regenerate'),
          onPressed: onRegenerate,
          icon: const Icon(Icons.refresh),
          label: const Text('New Words'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RegroupContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Text(
      'Regroup',
      key: const Key('cat_clock_regroup_label'),
      style: tt.titleLarge?.copyWith(
        color: cs.onSurfaceVariant,
        letterSpacing: 1,
      ),
    );
  }
}
