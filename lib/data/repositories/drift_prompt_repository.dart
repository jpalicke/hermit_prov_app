// ABOUTME: Drift-backed implementation of PromptRepository for on-device persistence.
// ABOUTME: Built-in prompts are served from an in-memory seed list; custom prompts are stored in SQLite.

import 'package:drift/drift.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';

class DriftPromptRepository implements PromptRepository {
  DriftPromptRepository(this._db, {required List<BuiltInPrompt> builtIns})
      : _builtIns = builtIns;

  final AppDatabase _db;
  final List<BuiltInPrompt> _builtIns;

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
    final query = _db.select(_db.customPrompts);
    if (category != null) {
      query.where((row) => row.category.equals(category.name));
    }
    final rows = await query.get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<void> addCustomPrompt(CustomPrompt prompt) async {
    await _db.into(_db.customPrompts).insert(_domainToCompanion(prompt));
  }

  @override
  Future<void> updateCustomPrompt(CustomPrompt prompt) async {
    _assertNotBuiltIn(prompt.id, action: 'update');
    await (_db.update(_db.customPrompts)
          ..where((row) => row.id.equals(prompt.id)))
        .write(_domainToCompanion(prompt));
  }

  @override
  Future<void> deleteCustomPrompt(String id) async {
    _assertNotBuiltIn(id, action: 'delete');
    await (_db.delete(_db.customPrompts)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  CustomPrompt _rowToDomain(CustomPromptData row) => CustomPrompt(
        id: row.id,
        text: row.promptText,
        category: PromptCategory.values.byName(row.category),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs),
      );

  CustomPromptsCompanion _domainToCompanion(CustomPrompt prompt) =>
      CustomPromptsCompanion(
        id: Value(prompt.id),
        promptText: Value(prompt.text),
        category: Value(prompt.category.name),
        createdAtMs: Value(prompt.createdAt.millisecondsSinceEpoch),
        updatedAtMs: Value(prompt.updatedAt.millisecondsSinceEpoch),
      );

  void _assertNotBuiltIn(String id, {required String action}) {
    if (_builtIns.any((p) => p.id == id)) {
      throw ArgumentError(
        'Cannot $action prompt "$id": built-in prompts are read-only.',
      );
    }
  }
}
