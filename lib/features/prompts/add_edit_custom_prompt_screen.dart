// ABOUTME: Screen for adding or editing a single custom prompt.
// ABOUTME: Validates the prompt text before saving; shows a generic error on block.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt_validator.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

class AddEditCustomPromptScreen extends StatefulWidget {
  const AddEditCustomPromptScreen({
    required this.existingPrompt,
    super.key,
  });

  /// Null when adding a new prompt; non-null when editing.
  final CustomPrompt? existingPrompt;

  @override
  State<AddEditCustomPromptScreen> createState() =>
      _AddEditCustomPromptScreenState();
}

class _AddEditCustomPromptScreenState
    extends State<AddEditCustomPromptScreen> {
  late final TextEditingController _textController;
  late PromptCategory _selectedCategory;
  String? _errorMessage;

  final _validator = CustomPromptValidator();

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.existingPrompt?.text ?? '');
    _selectedCategory =
        widget.existingPrompt?.category ?? PromptCategory.objects;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Suggestion text cannot be empty.');
      return;
    }

    final result = _validator.validate(text);
    if (!result.isValid) {
      setState(() {
        _errorMessage =
            "This suggestion can't be saved because it violates content rules.";
      });
      return;
    }

    final repo = AppServices.of(context).promptRepository;
    final now = DateTime.now();

    if (widget.existingPrompt == null) {
      // Add new
      final newPrompt = CustomPrompt(
        id: _generateId(),
        text: text,
        category: _selectedCategory,
        createdAt: now,
        updatedAt: now,
      );
      await repo.addCustomPrompt(newPrompt);
    } else {
      // Update existing
      final updated = CustomPrompt(
        id: widget.existingPrompt!.id,
        text: text,
        category: _selectedCategory,
        createdAt: widget.existingPrompt!.createdAt,
        updatedAt: now,
      );
      await repo.updateCustomPrompt(updated);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  String _generateId() {
    // Simple unique ID without uuid package — timestamp + random suffix.
    final ts = DateTime.now().microsecondsSinceEpoch;
    return 'custom-$ts';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPrompt != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Suggestion' : 'Add Suggestion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Suggestion text',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 16),
            _CategoryDropdown(
              value: _selectedCategory,
              onChanged: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.value,
    required this.onChanged,
  });

  final PromptCategory value;
  final ValueChanged<PromptCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PromptCategory>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: PromptCategory.values
          .map(
            (cat) => DropdownMenuItem(
              value: cat,
              child: Text(_label(cat)),
            ),
          )
          .toList(),
      onChanged: (cat) {
        if (cat != null) onChanged(cat);
      },
    );
  }

  String _label(PromptCategory cat) => switch (cat) {
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
