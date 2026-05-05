// ABOUTME: Placeholder History tab screen.
// ABOUTME: Will be expanded with practice stats and journal sections in a later prompt.

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(
        child: Text('Practice history'),
      ),
    );
  }
}
