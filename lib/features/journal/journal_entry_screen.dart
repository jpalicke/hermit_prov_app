// ABOUTME: Screen for creating or editing a single practice journal entry.
// ABOUTME: Supports optional drill tag selection and delete with confirmation.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key, this.entry});

  /// The entry to edit. If null, the screen operates in create mode.
  final JournalEntry? entry;

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late final TextEditingController _bodyController;
  DrillId? _selectedDrillId;

  bool get _isEditMode => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.entry?.body ?? '');
    _selectedDrillId = widget.entry?.drillId;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry cannot be empty')),
      );
      return;
    }

    final repo = AppServices.of(context).journalRepository;
    final now = DateTime.now();

    if (_isEditMode) {
      final updated = widget.entry!.copyWith(
        body: body,
        updatedAt: now,
        drillId: _selectedDrillId,
      );
      await repo.updateEntry(updated);
    } else {
      final entry = JournalEntry(
        id: now.millisecondsSinceEpoch.toString(),
        body: body,
        createdAt: now,
        updatedAt: now,
        drillId: _selectedDrillId,
      );
      await repo.addEntry(entry);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      final repo = AppServices.of(context).journalRepository;
      await repo.deleteEntry(widget.entry!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete entry',
              onPressed: _confirmDelete,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save entry',
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _bodyController,
                autofocus: !_isEditMode,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write about your practice...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Drill tag (optional)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _DrillTagSelector(
              selected: _selectedDrillId,
              onChanged: (id) => setState(() => _selectedDrillId = id),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DrillTagSelector extends StatelessWidget {
  const _DrillTagSelector({
    required this.selected,
    required this.onChanged,
  });

  final DrillId? selected;
  final ValueChanged<DrillId?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('None'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final drill in DrillId.values)
          ChoiceChip(
            label: Text(drill.displayName),
            selected: selected == drill,
            onSelected: (_) => onChanged(drill),
          ),
      ],
    );
  }
}
