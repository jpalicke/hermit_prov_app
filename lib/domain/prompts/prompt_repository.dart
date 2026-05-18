// ABOUTME: Repository interface for reading built-in and custom prompts.
// ABOUTME: Built-in prompts are read-only; custom prompts support full CRUD.

import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

abstract interface class PromptRepository {
  Future<List<BuiltInPrompt>> getBuiltInPrompts({PromptCategory? category});
  Future<List<CustomPrompt>> getCustomPrompts({PromptCategory? category});
  Future<void> addCustomPrompt(CustomPrompt prompt);
  Future<void> updateCustomPrompt(CustomPrompt prompt);
  Future<void> deleteCustomPrompt(String id);

  /// Deletes all custom prompts. Built-in prompts are not affected.
  Future<void> clearAll();
}
