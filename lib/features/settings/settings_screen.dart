// ABOUTME: Placeholder Settings tab screen.
// ABOUTME: Will be expanded with appearance, TTS, and data backup sections in a later prompt.

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings'),
      ),
    );
  }
}
