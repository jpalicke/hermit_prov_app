// ABOUTME: Placeholder Drill Start screen shown when a drill card is tapped.
// ABOUTME: Shows drill name, Start, Configure, and info/help controls — all non-functional until Prompt 9.

import 'package:flutter/material.dart';

class DrillStartScreen extends StatelessWidget {
  const DrillStartScreen({super.key, required this.drillName});

  final String drillName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drillName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
            tooltip: 'Help',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              drillName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Configure'),
            ),
          ],
        ),
      ),
    );
  }
}
