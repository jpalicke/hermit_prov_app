// ABOUTME: Placeholder Tools screen reachable from the Practice home Tools card.
// ABOUTME: Will be expanded with Prompt Generator, Timer, Emotion Wheel, and Journal in Prompt 7.

import 'package:flutter/material.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: const Center(
        child: Text('Prompt generator, timer, emotion wheel, journal.'),
      ),
    );
  }
}
