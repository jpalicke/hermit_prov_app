// ABOUTME: Active session screen for the Character Creation drill.
// ABOUTME: First pass shows label + Generate Prompt button; return pass shows label only, no prompt.

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
      contentBuilder: (context, state) {
        final seg = state.currentSegment;
        if (seg == null) return const SizedBox.shrink();

        final passType =
            CharacterCreationCycleBuilder.passTypeForId(seg.id);
        final isFirstPass = passType == CharacterCreationPassType.firstPass;
        final prompt = _prompts[seg.id];

        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character label.
            Text(
              seg.label ?? seg.id,
              key: Key('char_label_${seg.id}'),
              textAlign: TextAlign.center,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            if (isFirstPass) ...[
              const SizedBox(height: 16),
              // Prompt display area.
              if (prompt != null)
                Text(
                  prompt,
                  key: Key('char_prompt_${seg.id}'),
                  textAlign: TextAlign.center,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
              const SizedBox(height: 12),
              // Generate Prompt button — first pass only.
              FilledButton.tonal(
                key: const Key('generate_prompt_button'),
                onPressed: () => _generatePromptForSegment(seg.id),
                child: const Text('Generate Prompt'),
              ),
            ],
            // Return pass: no prompt button, no prompt display.
          ],
        );
      },
    );
  }
}
