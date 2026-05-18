// ABOUTME: Active session screen for the Cat/Clock drill.
// ABOUTME: Builds segment sequences with live prompts and wraps the shared DrillSessionShell.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/cat_clock/cat_clock_sequence.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/features/practice/drill_session_shell.dart';

class CatClockSessionScreen extends StatefulWidget {
  const CatClockSessionScreen({
    super.key,
    required this.settings,
    required this.promptRepository,
    required this.onSessionEnd,
  });

  final CatClockSettings settings;
  final PromptRepository promptRepository;
  final VoidCallback onSessionEnd;

  @override
  State<CatClockSessionScreen> createState() => _CatClockSessionScreenState();
}

class _CatClockSessionScreenState extends State<CatClockSessionScreen> {
  static const _sequence = CatClockSequence();

  DrillSessionController? _controller;
  String? _prompt1;
  String? _prompt2;
  int _repIndex = 0;

  @override
  void initState() {
    super.initState();
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
          tickDuration: const Duration(seconds: 1),
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
