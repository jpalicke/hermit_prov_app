// ABOUTME: Active session screen for the Two-Character Scenes drill.
// ABOUTME: Shows one prompt during the scene; regroup shows no prompt. No character labels.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/drills/two_character/two_character_sequence.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

class TwoCharacterSessionScreen extends StatefulWidget {
  const TwoCharacterSessionScreen({
    super.key,
    required this.settings,
    required this.promptRepository,
    required this.onSessionEnd,
  });

  final TwoCharacterScenesSettings settings;
  final PromptRepository promptRepository;
  final VoidCallback onSessionEnd;

  @override
  State<TwoCharacterSessionScreen> createState() =>
      _TwoCharacterSessionScreenState();
}

class _TwoCharacterSessionScreenState
    extends State<TwoCharacterSessionScreen> {
  static const _sequence = TwoCharacterSequence();

  DrillSessionController? _controller;
  String? _prompt;
  int _repIndex = 0;

  @override
  void initState() {
    super.initState();
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
          tickDuration: const Duration(seconds: 1),
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
        tickDuration: const Duration(seconds: 1),
      );
      if (wasRunning) _controller!.start();
    });
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
      contentBuilder: (context, state) {
        final seg = state.currentSegment;
        if (seg == null) return const SizedBox.shrink();

        _onStateChanged(state);

        if (seg.type == DrillSegmentType.regroup) {
          return const SizedBox.shrink(); // Spec: regroup shows no prompt.
        }

        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;

        if (_prompt == null) return const SizedBox.shrink();

        return Text(
          _prompt!,
          key: const Key('two_char_prompt'),
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
