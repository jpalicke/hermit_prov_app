// ABOUTME: Active session screen for the A-to-C / Bad Idea / Initiation drill.
// ABOUTME: Rapid-fire single-prompt intervals, looping until stopped.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/atoc/atoc_sequence.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

class AtoCSessionScreen extends StatefulWidget {
  const AtoCSessionScreen({
    super.key,
    required this.settings,
    required this.promptRepository,
    required this.onSessionEnd,
    this.onConfigure,
  });

  final AtoCSettings settings;
  final PromptRepository promptRepository;
  final VoidCallback onSessionEnd;
  final VoidCallback? onConfigure;

  @override
  State<AtoCSessionScreen> createState() => _AtoCSessionScreenState();
}

class _AtoCSessionScreenState extends State<AtoCSessionScreen> {
  static const _sequence = AtoCSequence();

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
      onConfigure: widget.onConfigure,
      instructions:
          'A prompt appears and a countdown runs. React to the prompt out loud. '
          'When the timer hits, a new prompt appears automatically. Runs until you stop it.',
      contentBuilder: (context, state) {
        _onStateChanged(state);
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
