// ABOUTME: Test fake PromptRepository that hands out "Prompt 1", "Prompt 2", ... in order.
// ABOUTME: Makes prompt refreshes observable without depending on random picks.

import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';

/// Every [getBuiltInPrompts] call returns exactly one prompt with the next
/// number, and there are no custom prompts. With a single prompt category,
/// each PromptPicker pick therefore yields the next "Prompt N" in sequence.
class SequencedPromptRepository implements PromptRepository {
  int _next = 1;

  @override
  Future<List<BuiltInPrompt>> getBuiltInPrompts({
    PromptCategory? category,
  }) async {
    final n = _next++;
    return [
      BuiltInPrompt(
        id: 'seq_$n',
        text: 'Prompt $n',
        category: category ?? PromptCategory.objects,
      ),
    ];
  }

  @override
  Future<List<CustomPrompt>> getCustomPrompts({
    PromptCategory? category,
  }) async =>
      const [];

  @override
  Future<void> addCustomPrompt(CustomPrompt prompt) async {}

  @override
  Future<void> updateCustomPrompt(CustomPrompt prompt) async {}

  @override
  Future<void> deleteCustomPrompt(String id) async {}

  @override
  Future<void> clearAll() async {}
}
