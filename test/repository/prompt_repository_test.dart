// ABOUTME: Repository tests for InMemoryPromptRepository.
// ABOUTME: Verifies seed loading, custom prompt CRUD, and built-in read-only enforcement.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

void main() {
  late InMemoryPromptRepository repo;
  final now = DateTime(2026, 1, 1);

  setUp(() => repo = InMemoryPromptRepository());

  // ── Built-in prompts ──────────────────────────────────────────────────────

  group('built-in prompts', () {
    test('loads at least one prompt for every category', () async {
      for (final category in PromptCategory.values) {
        final prompts = await repo.getBuiltInPrompts(category: category);
        expect(prompts, isNotEmpty, reason: 'expected prompts for $category');
      }
    });

    test('getBuiltInPrompts with no filter returns all eight categories', () async {
      final all = await repo.getBuiltInPrompts();
      final categories = all.map((p) => p.category).toSet();
      expect(categories, containsAll(PromptCategory.values));
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
    test('custom prompt is stored separately from built-in prompts', () async {
      final custom = CustomPrompt(
        id: 'custom-1',
        text: 'a rubber duck',
        category: PromptCategory.objects,
        createdAt: now,
        updatedAt: now,
      );
      await repo.addCustomPrompt(custom);

      final customs = await repo.getCustomPrompts();
      expect(customs.any((p) => p.id == 'custom-1'), isTrue);

      final builtIns = await repo.getBuiltInPrompts();
      expect(builtIns.any((p) => p.id == 'custom-1'), isFalse);
    });

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

    test('custom prompt can be deleted', () async {
      await repo.addCustomPrompt(CustomPrompt(
        id: 'del-1',
        text: 'gone',
        category: PromptCategory.activities,
        createdAt: now,
        updatedAt: now,
      ));
      await repo.deleteCustomPrompt('del-1');

      final prompts = await repo.getCustomPrompts();
      expect(prompts.any((p) => p.id == 'del-1'), isFalse);
    });

    test('getCustomPrompts with no filter returns all custom prompts', () async {
      await repo.addCustomPrompt(CustomPrompt(
        id: 'a', text: 'alpha', category: PromptCategory.objects,
        createdAt: now, updatedAt: now,
      ));
      await repo.addCustomPrompt(CustomPrompt(
        id: 'b', text: 'beta', category: PromptCategory.locations,
        createdAt: now, updatedAt: now,
      ));

      final all = await repo.getCustomPrompts();
      expect(all.length, 2);
    });
  });
}
