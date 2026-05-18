// ABOUTME: Active session screen for the Character Creation drill.
// ABOUTME: First pass shows prompt + label; return pass shows label only, no prompt.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/character_creation/character_creation_cycle.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

class CharacterCreationSessionScreen extends StatefulWidget {
  const CharacterCreationSessionScreen({
    super.key,
    required this.settings,
    required this.onSessionEnd,
    this.onConfigure,
  });

  final CharacterCreationSettings settings;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;

  @override
  State<CharacterCreationSessionScreen> createState() =>
      _CharacterCreationSessionScreenState();
}

class _CharacterCreationSessionScreenState
    extends State<CharacterCreationSessionScreen> {
  static const _builder = CharacterCreationCycleBuilder();

  DrillSessionController? _controller;

  // Maps segment id → generated prompt text.
  final Map<String, String> _prompts = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DrillSessionShell(
      controller: ctrl,
      onSessionEnd: widget.onSessionEnd,
      onConfigure: widget.onConfigure,
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
