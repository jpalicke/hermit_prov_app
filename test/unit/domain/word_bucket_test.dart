// ABOUTME: Unit tests verifying the word bucket contains all six prompt categories.
// ABOUTME: The word bucket is the union of all PromptCategory values.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

void main() {
  group('PromptCategory word bucket', () {
    test('contains all six prompt categories', () {
      expect(PromptCategory.wordBucket.length, 6);
      expect(PromptCategory.wordBucket, containsAll(PromptCategory.values));
    });

    test('contains objects', () {
      expect(PromptCategory.wordBucket, contains(PromptCategory.objects));
    });

    test('contains locations', () {
      expect(PromptCategory.wordBucket, contains(PromptCategory.locations));
    });

    test('contains relationships', () {
      expect(PromptCategory.wordBucket, contains(PromptCategory.relationships));
    });

    test('contains occupations', () {
      expect(PromptCategory.wordBucket, contains(PromptCategory.occupations));
    });

    test('contains emotions', () {
      expect(PromptCategory.wordBucket, contains(PromptCategory.emotions));
    });

    test('contains activities', () {
      expect(PromptCategory.wordBucket, contains(PromptCategory.activities));
    });
  });
}
