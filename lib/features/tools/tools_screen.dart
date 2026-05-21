// ABOUTME: Tools screen listing the utility tools available in the app.
// ABOUTME: Links to Suggestion Generator, Suggestion Bank, Journal, Timer, and Emotion Wheel.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/features/journal/journal_screen.dart';
import 'package:hermit_prov_app/features/prompts/custom_prompts_screen.dart';
import 'package:hermit_prov_app/features/tools/emotion_wheel_screen.dart';
import 'package:hermit_prov_app/features/tools/prompt_generator_screen.dart';
import 'package:hermit_prov_app/features/tools/timer_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        children: [
          _ToolTile(
            icon: Icons.shuffle,
            title: 'Suggestion Generator',
            subtitle: 'get a suggestion from a number of categories',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PromptGeneratorScreen(),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.edit_note,
            title: 'Add words to the suggestion bank',
            subtitle: 'pretty self-explanatory, actually',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CustomPromptsScreen(),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.book_outlined,
            title: 'Journal',
            subtitle: 'Write notes about your practice.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const JournalScreen(),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.timer_outlined,
            title: 'Timer',
            subtitle: 'Simple countdown or work/rest interval timer.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TimerScreen(),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.sentiment_satisfied_alt,
            title: 'Emotion Wheel',
            subtitle: 'browse the emotion wheel and search your feelings',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EmotionWheelScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
