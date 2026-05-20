// ABOUTME: Journal list screen showing all practice journal entries newest-first.
// ABOUTME: Provides FAB to create new entries and tap-to-edit for existing ones.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/features/journal/journal_entry_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry>? _entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final repo = AppServices.of(context).journalRepository;
    final entries = await repo.getEntries();
    if (mounted) {
      setState(() => _entries = entries);
    }
  }

  Future<void> _openCreateScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const JournalEntryScreen(),
      ),
    );
    _loadEntries();
  }

  Future<void> _openEditScreen(JournalEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalEntryScreen(entry: entry),
      ),
    );
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'New journal entry',
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final entries = _entries;
    if (entries == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (entries.isEmpty) {
      return const Center(
        child: Text('No journal entries yet. Tap + to write your first entry.'),
      );
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _JournalEntryTile(
          entry: entries[index],
          onTap: () => _openEditScreen(entries[index]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _JournalEntryTile extends StatelessWidget {
  const _JournalEntryTile({
    required this.entry,
    required this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final preview = entry.body.length > 100
        ? '${entry.body.substring(0, 100)}...'
        : entry.body;

    final drillLabel = entry.drillId != null ? ', drill: ${entry.drillId!.displayName}' : '';
    return Semantics(
      button: true,
      label: 'Journal entry from ${_formatDate(entry.createdAt)}$drillLabel. $preview',
      child: ExcludeSemantics(
        child: ListTile(
          title: Text(_formatDate(entry.createdAt)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.drillId != null) ...[
                const SizedBox(height: 2),
                Chip(
                  label: Text(
                    entry.drillId!.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: cs.secondaryContainer,
                ),
                const SizedBox(height: 2),
              ],
              Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  /// Formats a DateTime as "Month D, YYYY" e.g. "May 18, 2026".
  String _formatDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
