// ABOUTME: Reusable drill start screen with name, subtitle, Start, Configure, and Help buttons.
// ABOUTME: Used by every drill as the entry point; navigates to session shell or config screen.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';

/// Reusable start screen for any drill.
///
/// [subtitle] — one-line description shown below the drill name.
/// [onStart] — called when the user taps "Start".
/// [onConfigure] — called when the user taps "Configure".
/// [onHelp] — called when the user taps the info/help icon (optional).
class DrillStartScreen extends StatelessWidget {
  const DrillStartScreen({
    super.key,
    required this.drillId,
    this.subtitle,
    required this.onStart,
    required this.onConfigure,
    this.onHelp,
  });

  final DrillId drillId;
  final String? subtitle;
  final VoidCallback onStart;
  final VoidCallback onConfigure;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            key: const Key('drill_start_help_button'),
            onPressed: onHelp ?? () => _showDefaultHelp(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Help',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      drillId.displayName,
                      textAlign: TextAlign.center,
                      key: const Key('drill_start_name'),
                      style: tt.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        key: const Key('drill_start_subtitle'),
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            FilledButton(
              key: const Key('drill_start_start_button'),
              onPressed: onStart,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Start'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('drill_start_configure_button'),
              onPressed: onConfigure,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Configure'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDefaultHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(drillId.displayName),
        content:
            Text(subtitle ?? 'No additional help available for this drill.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
