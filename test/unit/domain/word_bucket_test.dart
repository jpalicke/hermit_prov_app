// ABOUTME: Unit tests verifying the word bucket contains all eight prompt categories.
// ABOUTME: The word bucket is the union of all PromptCategory values.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

void main() {
  group('PromptCategory word bucket', () {
    test('contains all eight prompt categories', () {
      expect(PromptCategory.wordBucket.length, 8);
      expect(PromptCategory.wordBucket, containsAll(PromptCategory.values));
    });
  });
}
