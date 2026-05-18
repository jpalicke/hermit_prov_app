// ABOUTME: Tools screen listing the four utility tools available in the app.
// ABOUTME: Links to Prompt Generator, Custom Prompts, Timer (placeholder), and Emotion Wheel (placeholder).

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/features/prompts/custom_prompts_screen.dart';
import 'package:hermit_prov_app/features/tools/prompt_generator_screen.dart';

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
            title: 'Prompt Generator',
            subtitle: 'Get a random prompt from any category mix.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PromptGeneratorScreen(),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.edit_note,
            title: 'Custom Prompts',
            subtitle: 'Add, edit, and delete your own prompts.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CustomPromptsScreen(),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.timer_outlined,
            title: 'Timer',
            subtitle: 'Coming soon.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Timer coming soon.')),
            ),
          ),
          _ToolTile(
            icon: Icons.sentiment_satisfied_alt,
            title: 'Emotion Wheel',
            subtitle: 'Coming soon.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Emotion Wheel coming soon.')),
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
