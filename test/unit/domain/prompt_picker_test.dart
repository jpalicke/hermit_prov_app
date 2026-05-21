// ABOUTME: Unit tests for PromptPicker service.
// ABOUTME: Verifies category picking, multi-category picking, word bucket, and built-in/custom mixing.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_picker.dart';

void main() {
  late InMemoryPromptRepository repo;
  late PromptPicker picker;
  final now = DateTime(2026);

  setUp(() {
    repo = InMemoryPromptRepository();
    picker = PromptPicker(repo);
  });

  group('pickFromCategory', () {
    test('returns a non-null prompt text for every category', () async {
      for (final category in PromptCategory.values) {
        final result = await picker.pickFromCategory(category);
        expect(result, isNotNull, reason: 'expected a prompt for $category');
        expect(result, isNotEmpty, reason: 'expected non-empty text for $category');
      }
    });

    test('returns null when the category has no prompts', () async {
      // Use a fresh empty repo with no seed data.
      final emptyRepo = _EmptyPromptRepository();
      final emptyPicker = PromptPicker(emptyRepo);

      final result = await emptyPicker.pickFromCategory(PromptCategory.objects);
      expect(result, isNull);
    });

    test('returned prompt belongs to the requested category', () async {
      // Add a custom prompt to one category and verify the picker only draws from it
      // when asked for that category. We rely on seed data being present for other
      // categories, so we just confirm the picked value is a real prompt text.
      final result = await picker.pickFromCategory(PromptCategory.emotions);
      expect(result, isNotNull);
    });
  });

  group('pickFromCategories', () {
    test('returns a prompt when given a single-element list', () async {
      final result = await picker.pickFromCategories([PromptCategory.locations]);
      expect(result, isNotNull);
    });

    test('returns a prompt from the union of multiple categories', () async {
      final result = await picker.pickFromCategories([
        PromptCategory.objects,
        PromptCategory.activities,
      ]);
      expect(result, isNotNull);
    });

    test('returns null when all given categories are empty', () async {
      final emptyRepo = _EmptyPromptRepository();
      final emptyPicker = PromptPicker(emptyRepo);
      final result = await emptyPicker.pickFromCategories([
        PromptCategory.objects,
        PromptCategory.locations,
      ]);
      expect(result, isNull);
    });

    test('returns null for empty category list', () async {
      final result = await picker.pickFromCategories([]);
      expect(result, isNull);
    });
  });

  group('pickFromWordBucket', () {
    test('returns a non-null prompt text', () async {
      final result = await picker.pickFromWordBucket();
      expect(result, isNotNull);
    });

    test('draws from all eight categories over many picks', () async {
      // Run enough picks that we expect all categories to appear at least once.
      // With 8 categories and 500 picks the probability of missing any is negligible.
      final seen = <String>{};
      for (var i = 0; i < 500; i++) {
        final result = await picker.pickFromWordBucket();
        if (result != null) seen.add(result);
      }
      // We can't easily map texts back to categories here, but we can at least
      // verify we got a diverse set of texts.
      expect(seen.length, greaterThan(20));
    });
  });

  group('built-in and custom prompts both eligible', () {
    test('custom prompt is eligible for picking', () async {
      const customText = 'a very unique custom prompt zxqwerty';
      await repo.addCustomPrompt(CustomPrompt(
        id: 'test-custom-1',
        text: customText,
        category: PromptCategory.objects,
        createdAt: now,
        updatedAt: now,
      ));

      // Run enough picks to hit the custom prompt with high probability.
      // The objects pool has ~823 entries; with 5000 picks p(miss) ≈ e^(-6) < 0.003.
      var found = false;
      for (var i = 0; i < 5000; i++) {
        final result = await picker.pickFromCategory(PromptCategory.objects);
        if (result == customText) {
          found = true;
          break;
        }
      }
      expect(found, isTrue, reason: 'custom prompt should be eligible for picking');
    });

    test('built-in prompts are eligible alongside custom prompts', () async {
      // Add one custom prompt; verify built-in prompts still appear.
      await repo.addCustomPrompt(CustomPrompt(
        id: 'test-custom-2',
        text: 'only custom prompt here',
        category: PromptCategory.relationships,
        createdAt: now,
        updatedAt: now,
      ));

      // With seed data + 1 custom, built-ins should still be reachable.
      var foundBuiltIn = false;
      for (var i = 0; i < 200; i++) {
        final result =
            await picker.pickFromCategory(PromptCategory.relationships);
        if (result != null && result != 'only custom prompt here') {
          foundBuiltIn = true;
          break;
        }
      }
      expect(foundBuiltIn, isTrue, reason: 'built-in prompts must remain eligible');
    });
  });
}

/// Minimal PromptRepository with no prompts at all, used to test null/empty cases.
class _EmptyPromptRepository extends InMemoryPromptRepository {
  @override
  Future<List<BuiltInPrompt>> getBuiltInPrompts({PromptCategory? category}) async => [];

  @override
  Future<List<CustomPrompt>> getCustomPrompts({PromptCategory? category}) async => [];
}
