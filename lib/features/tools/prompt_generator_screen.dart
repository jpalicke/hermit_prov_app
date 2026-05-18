// ABOUTME: Standalone Prompt Generator tool screen.
// ABOUTME: Lets the user pick categories, generate a random prompt, and optionally auto-advance on a timer.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';

/// Available auto-advance intervals in seconds.
const List<int> _kAutoAdvanceIntervals = [15, 30, 45, 60];

class PromptGeneratorScreen extends StatefulWidget {
  const PromptGeneratorScreen({super.key});

  @override
  State<PromptGeneratorScreen> createState() => _PromptGeneratorScreenState();
}

class _PromptGeneratorScreenState extends State<PromptGeneratorScreen> {
  // Category selection — all selected by default.
  late Set<PromptCategory> _selectedCategories;

  String? _currentPrompt;

  bool _autoAdvance = false;
  int _autoAdvanceInterval = 30; // seconds
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.of(PromptCategory.values);
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  Future<void> _generatePrompt() async {
    if (_selectedCategories.isEmpty) return;
    final repo = AppServices.of(context).promptRepository;
    final picker = PromptPicker(repo);

    final prompt = await picker.pickFromCategories(_selectedCategories.toList());
    if (mounted) {
      setState(() => _currentPrompt = prompt ?? '(no prompts in selection)');
    }
  }

  void _toggleAutoAdvance(bool value) {
    setState(() {
      _autoAdvance = value;
    });
    if (value) {
      _startAutoAdvanceTimer();
    } else {
      _stopAutoAdvanceTimer();
    }
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(
      Duration(seconds: _autoAdvanceInterval),
      (_) => _generatePrompt(),
    );
  }

  void _stopAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  bool get _allSelected =>
      _selectedCategories.length == PromptCategory.values.length;

  void _toggleAllCategories() {
    setState(() {
      if (_allSelected) {
        _selectedCategories = {};
      } else {
        _selectedCategories = Set.of(PromptCategory.values);
      }
    });
  }

  void _toggleCategory(PromptCategory cat) {
    setState(() {
      if (_allSelected) {
        // Isolate: selecting one chip when all are selected narrows to just that one.
        _selectedCategories = {cat};
      } else if (_selectedCategories.contains(cat)) {
        _selectedCategories = Set.of(_selectedCategories)..remove(cat);
      } else {
        _selectedCategories = Set.of(_selectedCategories)..add(cat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Prompt display ───────────────────────────────────────────
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  key: const Key('prompt_display'),
                  _currentPrompt ?? '',
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── New Prompt button ────────────────────────────────────────
            FilledButton.icon(
              onPressed: _selectedCategories.isEmpty ? null : _generatePrompt,
              icon: const Icon(Icons.shuffle),
              label: const Text('New Prompt'),
            ),

            const SizedBox(height: 24),

            // ── Auto-advance toggle ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text('Auto-advance', style: tt.titleSmall),
                ),
                Switch(
                  value: _autoAdvance,
                  onChanged: _toggleAutoAdvance,
                ),
              ],
            ),

            if (_autoAdvance) ...[
              const SizedBox(height: 8),
              _IntervalSelector(
                selected: _autoAdvanceInterval,
                onChanged: (interval) {
                  setState(() => _autoAdvanceInterval = interval);
                  if (_autoAdvance) _startAutoAdvanceTimer();
                },
              ),
            ],

            const SizedBox(height: 24),

            // ── Category chips ───────────────────────────────────────────
            Text('Categories', style: tt.titleSmall),
            const SizedBox(height: 8),
            // Select All / Deselect All toggle button.
            FilledButton.tonal(
              key: const Key('select_all_categories_button'),
              onPressed: _toggleAllCategories,
              child: Text(
                _allSelected ? 'Deselect All Categories' : 'Select All Categories',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...PromptCategory.values.map(
                  (cat) => FilterChip(
                    label: Text(_categoryLabel(cat)),
                    selected: _selectedCategories.contains(cat),
                    onSelected: (_) => _toggleCategory(cat),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(PromptCategory cat) => switch (cat) {
    PromptCategory.objects => 'Objects',
    PromptCategory.locations => 'Locations',
    PromptCategory.relationships => 'Relationships',
    PromptCategory.occupations => 'Occupations',
    PromptCategory.emotions => 'Emotions',
    PromptCategory.activities => 'Activities',
    PromptCategory.genre => 'Genre',
    PromptCategory.events => 'Events',
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class _IntervalSelector extends StatelessWidget {
  const _IntervalSelector({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _kAutoAdvanceIntervals
          .map(
            (secs) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${secs}s'),
                selected: selected == secs,
                onSelected: (_) => onChanged(secs),
              ),
            ),
          )
          .toList(),
    );
  }
}
