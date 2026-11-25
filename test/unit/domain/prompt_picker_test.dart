// ABOUTME: Unit tests for PromptPicker service.
// ABOUTME: Verifies category picking, multi-category picking, word bucket, and built-in/custom mixing.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
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
  });
}
