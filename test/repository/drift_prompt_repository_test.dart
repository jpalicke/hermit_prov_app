// ABOUTME: Repository tests for DriftPromptRepository using an in-memory Drift database.
// ABOUTME: Verifies seed loading, custom prompt CRUD, and built-in read-only enforcement.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/data/repositories/drift_prompt_repository.dart';
import 'package:hermit_prov_app/data/seed/seed_prompts.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late DriftPromptRepository repo;
  final now = DateTime(2026);

  setUp(() {
    db = openTestDatabase();
    repo = DriftPromptRepository(db, builtIns: buildSeedPrompts());
  });

  tearDown(() => db.close());

  // ── Built-in prompts ──────────────────────────────────────────────────────

  group('built-in prompts', () {
    test('loads prompts for every category, filtered to that category',
        () async {
      for (final category in PromptCategory.values) {
        final prompts = await repo.getBuiltInPrompts(category: category);
        expect(prompts, isNotEmpty, reason: 'expected prompts for $category');
        expect(
          prompts.map((p) => p.category).toSet(),
          {category},
          reason: 'only $category prompts',
        );
      }
    });

    test('cannot delete a built-in prompt via custom prompt API', () async {
      final builtIns = await repo.getBuiltInPrompts();
      await expectLater(
        () => repo.deleteCustomPrompt(builtIns.first.id),
        throwsArgumentError,
      );
    });

    test('cannot update a built-in prompt via custom prompt API', () async {
      final builtIns = await repo.getBuiltInPrompts();
      final builtInId = builtIns.first.id;
      final fakeUpdate = CustomPrompt(
        id: builtInId,
        text: 'hijacked',
        category: PromptCategory.objects,
        createdAt: now,
        updatedAt: now,
      );
      await expectLater(
        () => repo.updateCustomPrompt(fakeUpdate),
        throwsArgumentError,
      );
    });
  });

  // ── Custom prompts ────────────────────────────────────────────────────────

  group('custom prompts', () {
    test('custom prompts can be filtered by category', () async {
      await repo.addCustomPrompt(CustomPrompt(
        id: 'obj-1',
        text: 'widget',
        category: PromptCategory.objects,
        createdAt: now,
        updatedAt: now,
      ));
      await repo.addCustomPrompt(CustomPrompt(
        id: 'loc-1',
        text: 'the moon',
        category: PromptCategory.locations,
        createdAt: now,
        updatedAt: now,
      ));

      final objects =
          await repo.getCustomPrompts(category: PromptCategory.objects);
      expect(objects.every((p) => p.category == PromptCategory.objects), isTrue);
      expect(objects.any((p) => p.id == 'obj-1'), isTrue);
      expect(objects.any((p) => p.id == 'loc-1'), isFalse);
    });

    test('custom prompt can be updated', () async {
      await repo.addCustomPrompt(CustomPrompt(
        id: 'upd-1',
        text: 'original',
        category: PromptCategory.emotions,
        createdAt: now,
        updatedAt: now,
      ));
      await repo.updateCustomPrompt(CustomPrompt(
        id: 'upd-1',
        text: 'updated',
        category: PromptCategory.emotions,
        createdAt: now,
        updatedAt: now,
      ));

      final prompts = await repo.getCustomPrompts();
      expect(prompts.firstWhere((p) => p.id == 'upd-1').text, 'updated');
    });
  });
}
