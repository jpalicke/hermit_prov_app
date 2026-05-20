// ABOUTME: Main app shell with a three-tab bottom navigation bar.
// ABOUTME: Uses IndexedStack so tab state is preserved when switching tabs.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/features/history/history_screen.dart';
import 'package:hermit_prov_app/features/practice/practice_screen.dart';
import 'package:hermit_prov_app/features/settings/settings_screen.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;
  int _historyVersion = 0;

  void _onTabTap(int index) {
    if (index == 1 && _currentIndex != 1) {
      _historyVersion++;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const PracticeScreen(),
          HistoryScreen(key: ValueKey(_historyVersion)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
