// ABOUTME: Practice tab home screen — the "Choose Your Drill" entry point.
// ABOUTME: Shows cards for all five drills and the Tools section; tapping navigates to each.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  // Drill names and subtitles drawn from the Hermit-Prov spec.
  static const List<({String name, String subtitle})> _drills = [
    (
      name: 'Cat/Clock',
      subtitle: 'Connect two prompts through association.',
    ),
    (
      name: 'Character Creation',
      subtitle: 'Cycle through solo character reps.',
    ),
    (
      name: 'Two-Character Scenes',
      subtitle: 'Prompt + timed two-character scene.',
    ),
    (
      name: 'A-to-C / Bad Idea / Initiation',
      subtitle: 'Rapid-fire prompt reps.',
    ),
    (
      name: 'Five Line Game Drill',
      subtitle: 'One prompt, fast five-line scenes.',
    ),
  ];

  void _openDrill(BuildContext context, String drillName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrillStartScreen(drillName: drillName),
      ),
    );
  }

  void _openTools(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ToolsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ..._drills.map(
            (drill) => _DrillCard(
              name: drill.name,
              subtitle: drill.subtitle,
              onTap: () => _openDrill(context, drill.name),
            ),
          ),
          _DrillCard(
            name: 'Tools',
            subtitle: 'Prompt generator, timer, emotion wheel, journal.',
            onTap: () => _openTools(context),
          ),
        ],
      ),
    );
  }
}

class _DrillCard extends StatelessWidget {
  const _DrillCard({
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
