// ABOUTME: Validates user-submitted custom prompts against a local blocklist.
// ABOUTME: Blocks slurs and graphic sexual content; allows non-graphic adult prompts.

sealed class PromptValidationResult {
  bool get isValid;
}

class PromptValid extends PromptValidationResult {
  @override
  bool get isValid => true;
}

class PromptInvalid extends PromptValidationResult {
  @override
  bool get isValid => false;
}

class CustomPromptValidator {
  static final _slurPatterns = [
    RegExp(r'\bnigger\b', caseSensitive: false),
    RegExp(r'\bnigga\b', caseSensitive: false),
    RegExp(r'\bcoon\b', caseSensitive: false),
    RegExp(r'\bkike\b', caseSensitive: false),
    RegExp(r'\bspic\b', caseSensitive: false),
    RegExp(r'\bchink\b', caseSensitive: false),
    RegExp(r'\bgook\b', caseSensitive: false),
    RegExp(r'\bfaggot\b', caseSensitive: false),
    RegExp(r'\bdyke\b', caseSensitive: false),
    RegExp(r'\bretard\b', caseSensitive: false),
  ];

  static final _explicitPatterns = [
    RegExp(r'\bfucking\b', caseSensitive: false),
    RegExp(r'\bcunt\b', caseSensitive: false),
    RegExp(r'\bporn\s+star\b', caseSensitive: false),
    RegExp(r'\banal\s+sex\b', caseSensitive: false),
  ];

  PromptValidationResult validate(String text) {
    for (final pattern in _slurPatterns) {
      if (pattern.hasMatch(text)) return PromptInvalid();
    }
    for (final pattern in _explicitPatterns) {
      if (pattern.hasMatch(text)) return PromptInvalid();
    }
    return PromptValid();
  }
}
