// ABOUTME: Repository tests for InMemoryPromptRepository.
// ABOUTME: Verifies built-in prompts cannot be deleted through the custom prompt API.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';

void main() {
  late InMemoryPromptRepository repo;

  setUp(() => repo = InMemoryPromptRepository());

  // ── Built-in prompts ──────────────────────────────────────────────────────

  group('built-in prompts', () {
    test('cannot delete a built-in prompt via custom prompt API', () async {
      final builtIns = await repo.getBuiltInPrompts();
      await expectLater(
        () => repo.deleteCustomPrompt(builtIns.first.id),
        throwsArgumentError,
      );
    });
  });
}
