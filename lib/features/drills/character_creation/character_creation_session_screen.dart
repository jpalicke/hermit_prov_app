// ABOUTME: Active session screen for the Character Creation drill.
// ABOUTME: First pass shows prompt + label; return pass shows label only, no prompt.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/character_creation/character_creation_cycle.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/tts/hands_free_announcement_policy.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

class CharacterCreationSessionScreen extends StatefulWidget {
  const CharacterCreationSessionScreen({
    super.key,
    required this.settings,
    required this.onSessionEnd,
    this.onConfigure,
    this.historyRepository,
    this.ttsService,
  });

  final CharacterCreationSettings settings;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;
  final PracticeHistoryRepository? historyRepository;

  /// When provided and [settings.handsFreeModeEnabled] is true, drives TTS
  /// announcements during the session. Null-safe: no-op when null.
  final TtsService? ttsService;

  @override
  State<CharacterCreationSessionScreen> createState() =>
      _CharacterCreationSessionScreenState();
}

class _CharacterCreationSessionScreenState
    extends State<CharacterCreationSessionScreen> {
  static const _builder = CharacterCreationCycleBuilder();

  DrillSessionController? _controller;

  // Maps segment id to generated prompt text.
  final Map<String, String> _prompts = {};

  HandsFreeAnnouncementPolicy? _policy;
  String? _lastAnnouncedSegmentId;

  bool get _handsFreeActive =>
      widget.settings.handsFreeModeEnabled && widget.ttsService != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      if (_handsFreeActive) {
        _policy = HandsFreeAnnouncementPolicy(widget.ttsService!);
      }
      _initController();
    }
  }

  void _initController() {
    final segments = _builder.buildCycle(widget.settings);
    setState(() {
      _controller = DrillSessionController(
        segments: segments,
        loops: false, // Finite: ends after the full cycle.
        tickDuration: const Duration(seconds: 1),
      );
    });
    // Auto-generate prompts for all first-pass segments.
    for (final seg in segments) {
      if (CharacterCreationCycleBuilder.passTypeForId(seg.id) ==
          CharacterCreationPassType.firstPass) {
        _generatePromptForSegment(seg.id);
      }
    }
  }

  Future<void> _generatePromptForSegment(String segmentId) async {
    final picker = PromptPicker(AppServices.of(context).promptRepository);
    final p = await picker.pickFromCategories(widget.settings.promptCategories);
    if (mounted && p != null) {
      setState(() => _prompts[segmentId] = p);
      // If this is the currently active first-pass segment, fire TTS.
      _maybeAnnounceFirstPassWithPrompt(segmentId, p);
    }
  }

  void _maybeAnnounceFirstPassWithPrompt(String segmentId, String prompt) {
    final policy = _policy;
    if (policy == null) return;
    final ctrl = _controller;
    if (ctrl == null) return;
    final currentSeg = ctrl.state.currentSegment;
    if (currentSeg == null || currentSeg.id != segmentId) return;
    // Only announce if we haven't announced this segment yet.
    if (_lastAnnouncedSegmentId == segmentId) return;
    _lastAnnouncedSegmentId = segmentId;
    final charNum = CharacterCreationCycleBuilder.characterNumberForId(segmentId);
    policy.onSegmentStart(
      currentSeg.copyWith(
        promptPayload: prompt,
        label: 'Character $charNum',
      ),
      paused: ctrl.state.isPaused,
    );
  }

  void _handleTick(DrillSessionState state) {
    final policy = _policy;
    if (policy == null) return;
    final seg = state.currentSegment;
    if (seg == null) return;

    final paused = state.isPaused;
    final passType = CharacterCreationCycleBuilder.passTypeForId(seg.id);
    final charNum = CharacterCreationCycleBuilder.characterNumberForId(seg.id);

    if (_lastAnnouncedSegmentId != seg.id) {
      _lastAnnouncedSegmentId = seg.id;

      if (passType == CharacterCreationPassType.returnPass) {
        // Return pass: speak "Character N".
        policy.onSegmentStart(
          seg.copyWith(label: 'Return to Character $charNum'),
          paused: paused,
        );
      } else {
        // First pass: try to announce with prompt if available.
        final prompt = _prompts[seg.id];
        if (prompt != null) {
          policy.onSegmentStart(
            seg.copyWith(
              promptPayload: prompt,
              label: 'Character $charNum',
            ),
            paused: paused,
          );
        }
        // If prompt is not ready yet, _maybeAnnounceFirstPassWithPrompt
        // will fire once the prompt generation completes.
      }
    }

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
      drillId: DrillId.characterCreation,
      autoStart: true,
      instructions:
          'Each segment is one character. On the first pass, a prompt appears automatically. '
          'Tap New Prompt if you want a different one. On the return pass, return to that character. '
          'No prompt is shown on return passes. The session ends when every character has had '
          'both the initial and return passes.',
      ringLabelBuilder: (state) {
        final seg = state.currentSegment;
        return seg?.label;
      },
      contentBuilder: (context, state) {
        _handleTick(state);
        final seg = state.currentSegment;
        if (seg == null) return const SizedBox.shrink();

        final passType =
            CharacterCreationCycleBuilder.passTypeForId(seg.id);
        final isFirstPass = passType == CharacterCreationPassType.firstPass;
        final prompt = _prompts[seg.id];

        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;

        if (!isFirstPass) {
          // Return pass: show only the character label, no prompt, no button.
          return Text(
            seg.label ?? seg.id,
            key: Key('char_label_${seg.id}'),
            textAlign: TextAlign.center,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          );
        }

        // First pass: prompt is the hero above the character label.
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prompt text — hero display.
            if (prompt != null)
              Text(
                prompt,
                key: Key('char_prompt_${seg.id}'),
                textAlign: TextAlign.center,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            const SizedBox(height: 8),
            // Character label below the prompt.
            Text(
              seg.label ?? seg.id,
              key: Key('char_label_${seg.id}'),
              textAlign: TextAlign.center,
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // New Prompt button — first pass only.
            FilledButton.tonal(
              key: const Key('generate_prompt_button'),
              onPressed: () => _generatePromptForSegment(seg.id),
              child: const Text('New Prompt'),
            ),
          ],
        );
      },
    );
  }
}
