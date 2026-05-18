// ABOUTME: Picks random prompts from the repository across one or more categories.
// ABOUTME: Combines built-in and custom prompts transparently.

import 'dart:math';

import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';

class PromptPicker {
  PromptPicker(this._repository);

  final PromptRepository _repository;
  final _random = Random();

  Future<String?> pickFromCategory(PromptCategory category) =>
      pickFromCategories([category]);

  Future<String?> pickFromCategories(List<PromptCategory> categories) async {
    if (categories.isEmpty) return null;
    final texts = <String>[];
    for (final category in categories) {
      final builtIns =
          await _repository.getBuiltInPrompts(category: category);
      final customs =
          await _repository.getCustomPrompts(category: category);
      texts.addAll(builtIns.map((p) => p.text));
      texts.addAll(customs.map((p) => p.text));
    }
    if (texts.isEmpty) return null;
    return texts[_random.nextInt(texts.length)];
  }

  Future<String?> pickFromWordBucket() =>
      pickFromCategories(PromptCategory.values.toList());
}
