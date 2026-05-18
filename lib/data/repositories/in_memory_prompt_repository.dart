// ABOUTME: In-memory implementation of PromptRepository backed by seed prompts.
// ABOUTME: Built-in prompts are read-only; custom prompts are stored in a mutable map.

import 'package:hermit_prov_app/data/seed/seed_prompts.dart';
import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';

class InMemoryPromptRepository implements PromptRepository {
  InMemoryPromptRepository() : _builtIns = buildSeedPrompts();

  final List<BuiltInPrompt> _builtIns;

  /// Keyed by [CustomPrompt.id] to allow O(1) updates and deletes.
  final Map<String, CustomPrompt> _customs = {};

  @override
  Future<List<BuiltInPrompt>> getBuiltInPrompts({
    PromptCategory? category,
  }) async {
    if (category == null) return List.unmodifiable(_builtIns);
    return _builtIns.where((p) => p.category == category).toList();
  }

  @override
  Future<List<CustomPrompt>> getCustomPrompts({
    PromptCategory? category,
  }) async {
    final all = _customs.values;
    if (category == null) return all.toList();
    return all.where((p) => p.category == category).toList();
  }

  @override
  Future<void> addCustomPrompt(CustomPrompt prompt) async {
    _customs[prompt.id] = prompt;
  }

  @override
  Future<void> updateCustomPrompt(CustomPrompt prompt) async {
    _assertNotBuiltIn(prompt.id, action: 'update');
    if (!_customs.containsKey(prompt.id)) {
      throw ArgumentError('No custom prompt with id "${prompt.id}"');
    }
    _customs[prompt.id] = prompt;
  }

  @override
  Future<void> deleteCustomPrompt(String id) async {
    _assertNotBuiltIn(id, action: 'delete');
    _customs.remove(id);
  }

  @override
  Future<void> clearAll() async => _customs.clear();

  // ── helpers ────────────────────────────────────────────────────────────────

  void _assertNotBuiltIn(String id, {required String action}) {
    if (_builtIns.any((p) => p.id == id)) {
      throw ArgumentError(
        'Cannot $action prompt "$id": built-in prompts are read-only.',
      );
    }
  }
}
