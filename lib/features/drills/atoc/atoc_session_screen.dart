// ABOUTME: Active session screen for the A-to-C / Bad Idea / Initiation drill.
// ABOUTME: Rapid-fire single-prompt intervals, looping until stopped.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/atoc/atoc_sequence.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/domain/tts/hands_free_announcement_policy.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

class AtoCSessionScreen extends StatefulWidget {
  const AtoCSessionScreen({
    required this.settings,
    required this.promptRepository,
    required this.onSessionEnd,
    super.key,
    this.onConfigure,
    this.historyRepository,
    this.ttsService,
  });

  final AtoCSettings settings;
  final PromptRepository promptRepository;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;
  final PracticeHistoryRepository? historyRepository;

  /// When provided and [settings.handsFreeModeEnabled] is true, drives TTS
  /// announcements during the session. Null-safe: no-op when null.
  final TtsService? ttsService;

  @override
  State<AtoCSessionScreen> createState() => _AtoCSessionScreenState();
}

class _AtoCSessionScreenState extends State<AtoCSessionScreen> {
  static const _sequence = AtoCSequence();

  DrillSessionController? _controller;
  String? _prompt;
  int _repIndex = 0;
  HandsFreeAnnouncementPolicy? _policy;
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
    await _loadPrompt();
    final segs = _sequence.buildRep(
      settings: widget.settings,
      prompt: _prompt,
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

  Future<void> _loadPrompt() async {
    final picker = PromptPicker(widget.promptRepository);
    _prompt =
        await picker.pickFromCategories(widget.settings.promptCategories);
  }

  void _onStateChanged(DrillSessionState state) {
    if (state.loops > _repIndex) {
      _repIndex = state.loops;
      _regeneratePrompt();
    }
  }

  Future<void> _regeneratePrompt() async {
    await _loadPrompt();
    if (!mounted || _controller == null) return;
    final newSegs = _sequence.buildRep(
      settings: widget.settings,
      prompt: _prompt,
      repIndex: _repIndex,
    );
    setState(() {
      final wasRunning = _controller!.state.isRunning;
      _controller = DrillSessionController(
        segments: newSegs,
        loops: true,
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

    // AtoC default interval is 30 s — no timer announcements per spec.
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
      drillId: DrillId.atoC,
      autoStart: widget.settings.handsFreeModeEnabled,
      instructions:
          'A suggestion appears and a countdown runs. React to the suggestion out loud. '
          'When the timer hits, a new suggestion appears automatically. Runs until you stop it.',
      contentBuilder: (context, state) {
        _onStateChanged(state);
        _handleTick(state);
        if (_prompt == null) return const SizedBox.shrink();

        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;

        return Text(
          _prompt!,
          key: const Key('atoc_prompt'),
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
