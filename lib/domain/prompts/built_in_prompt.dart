// ABOUTME: Model for a built-in read-only prompt bundled with the app.
// ABOUTME: Built-in prompts cannot be edited or deleted by the user.

import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

class BuiltInPrompt {
  const BuiltInPrompt({
    required this.id,
    required this.text,
    required this.category,
  });

  final String id;
  final String text;
  final PromptCategory category;
}
