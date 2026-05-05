// ABOUTME: Placeholder Practice tab screen shown on app launch.
// ABOUTME: Will be replaced by the Choose Your Drill screen in Prompt 2.

import 'package:flutter/material.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: const Center(
        child: Text('Choose your drill'),
      ),
    );
  }
}
