// ABOUTME: Suggestion bank screen — manage user-created prompts, grouped by category.
// ABOUTME: Supports add, edit, and delete operations; built-in prompts are never shown here.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/features/prompts/add_edit_custom_prompt_screen.dart';

class CustomPromptsScreen extends StatefulWidget {
  const CustomPromptsScreen({super.key});

  @override
  State<CustomPromptsScreen> createState() => _CustomPromptsScreenState();
}

class _CustomPromptsScreenState extends State<CustomPromptsScreen> {
  List<CustomPrompt> _prompts = [];
  bool _loading = true;
  bool _initialized = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadPrompts();
    }
  }

  Future<void> _loadPrompts() async {
    final repo = AppServices.of(context).promptRepository;
    try {
      final prompts = await repo.getCustomPrompts();
      if (mounted) {
        setState(() {
          _prompts = prompts;
          _loading = false;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _retryLoad() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _loadPrompts();
  }

  Future<void> _addPrompt() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddEditCustomPromptScreen(
          existingPrompt: null,
        ),
      ),
    );
    if (result ?? false) {
      await _loadPrompts();
    }
  }

  Future<void> _editPrompt(CustomPrompt prompt) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditCustomPromptScreen(
          existingPrompt: prompt,
        ),
      ),
    );
    if (result ?? false) {
      await _loadPrompts();
    }
  }

  Future<void> _deletePrompt(CustomPrompt prompt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prompt?'),
        content: Text('Delete "${prompt.text}"? This cannot be undone.'),
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
      final repo = AppServices.of(context).promptRepository;
      await repo.deleteCustomPrompt(prompt.id);
      await _loadPrompts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add words to the suggestion bank'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPrompt,
        tooltip: 'Add Prompt',
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _prompts.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No custom prompts yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _buildGroupedList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              key: Key('load_error_message'),
              'Could not load prompts. Please try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _retryLoad,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList() {
    // Group prompts by category
    final grouped = <PromptCategory, List<CustomPrompt>>{};
    for (final category in PromptCategory.values) {
      final categoryPrompts =
          _prompts.where((p) => p.category == category).toList();
      if (categoryPrompts.isNotEmpty) {
        grouped[category] = categoryPrompts;
      }
    }

    final sections = <Widget>[];
    for (final entry in grouped.entries) {
      sections.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            entry.key.displayLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
      for (final prompt in entry.value) {
        sections.add(_PromptTile(
          prompt: prompt,
          onEdit: () => _editPrompt(prompt),
          onDelete: () => _deletePrompt(prompt),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: sections,
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────

class _PromptTile extends StatelessWidget {
  const _PromptTile({
    required this.prompt,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomPrompt prompt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(prompt.text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
