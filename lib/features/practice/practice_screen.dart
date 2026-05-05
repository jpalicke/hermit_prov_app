// ABOUTME: Practice tab home screen — the "Choose Your Drill" entry point.
// ABOUTME: Shows cards for all five drills and the Tools section; tapping navigates to each.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/features/practice/drill_start_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  static final List<({DrillId drillId, String subtitle, Widget icon, Color color})> _drills = [
    (
      drillId: DrillId.catClock,
      subtitle: 'Connect two prompts through association.',
      icon: const FaIcon(FontAwesomeIcons.cat, color: Colors.white, size: 20),
      color: const Color(0xFF0EA5E9), // sky blue
    ),
    (
      drillId: DrillId.characterCreation,
      subtitle: 'Cycle through solo character reps.',
      icon: const Icon(Icons.person, color: Colors.white, size: 24),
      color: const Color(0xFFF97316), // vivid orange
    ),
    (
      drillId: DrillId.twoCharacterScenes,
      subtitle: 'Prompt + timed two-character scene.',
      icon: const Icon(Icons.people, color: Colors.white, size: 24),
      color: const Color(0xFF22C55E), // vivid green
    ),
    (
      drillId: DrillId.atoC,
      subtitle: 'Rapid-fire prompt reps.',
      icon: const Icon(Icons.flash_on, color: Colors.white, size: 24),
      color: const Color(0xFFEF4444), // vivid red
    ),
    (
      drillId: DrillId.fiveLineGame,
      subtitle: 'One prompt, fast five-line scenes.',
      icon: const FaIcon(FontAwesomeIcons.film, color: Colors.white, size: 20),
      color: const Color(0xFF7C3AED), // violet (matches brand seed)
    ),
  ];

  void _openDrill(BuildContext context, DrillId drillId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrillStartScreen(drillId: drillId),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Choose Your Drill',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            centerTitle: false,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            forceElevated: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._drills.map(
                  (drill) => _DrillCard(
                    drillId: drill.drillId,
                    subtitle: drill.subtitle,
                    icon: drill.icon,
                    color: drill.color,
                    onTap: () => _openDrill(context, drill.drillId),
                  ),
                ),
                _ToolsCard(onTap: () => _openTools(context)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DrillCard extends StatelessWidget {
  const _DrillCard({
    required this.drillId,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final DrillId drillId;
  final String subtitle;
  final Widget icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: cs.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drillId.displayName,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ToolsCard extends StatelessWidget {
  const _ToolsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.handyman_outlined,
                    color: cs.onSecondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tools',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prompt generator, timer, emotion wheel, journal.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
