// ABOUTME: Model for a user-created custom prompt stored locally on device.
// ABOUTME: Custom prompts are validated before saving and stored separately from built-ins.

import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

class CustomPrompt {
  const CustomPrompt({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String text;
  final PromptCategory category;
  final DateTime createdAt;
}
