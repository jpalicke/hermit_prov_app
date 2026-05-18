// ABOUTME: Reusable base scaffold for drill configuration screens.
// ABOUTME: Each drill supplies its own form body; this handles AppBar, Save button, and layout.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';

/// Reusable configuration screen scaffold.
///
/// [drillId] — used for the AppBar title.
/// [body] — the drill-specific settings form.
/// [onSave] — called when the user taps "Save"; should persist settings.
class DrillConfigureScreen extends StatelessWidget {
  const DrillConfigureScreen({
    super.key,
    required this.drillId,
    required this.body,
    required this.onSave,
  });

  final DrillId drillId;
  final Widget body;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${drillId.displayName} — Configure',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: body,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: FilledButton(
              key: const Key('drill_configure_save_button'),
              onPressed: onSave,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
