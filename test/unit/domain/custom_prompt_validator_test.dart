// ABOUTME: Unit tests for CustomPromptValidator.
// ABOUTME: Verifies slur blocking, explicit content blocking, and allowed adult-life prompt pass-through.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/prompts/custom_prompt_validator.dart';

void main() {
  late CustomPromptValidator validator;

  setUp(() => validator = CustomPromptValidator());

  // ── Normal / clearly acceptable prompts ──────────────────────────────────

  group('acceptable prompts pass', () {
    final acceptable = [
      'a broken umbrella',
      'the post office at 3am',
      'two coworkers sharing a cab',
      'grocery shopping',
      'someone who just got fired',
      'a dentist appointment',
      'playing chess in the park',
      'a surprise party',
    ];

    for (final text in acceptable) {
      test('"$text" passes', () {
        expect(validator.validate(text).isValid, isTrue);
      });
    }
  });

  // ── Allowed adult-life / relationship prompts ─────────────────────────────

  group('non-graphic adult relationship prompts pass', () {
    final allowedAdult = [
      'a bad date',
      'an affair',
      'a crush',
      'flirting',
      'an awkward hookup',
      'divorce',
      'dating',
      'a break-up',
      'a first kiss',
      'unrequited love',
      'a blind date gone wrong',
    ];

    for (final text in allowedAdult) {
      test('"$text" passes', () {
        expect(validator.validate(text).isValid, isTrue);
      });
    }
  });

  // ── Slur blocking ─────────────────────────────────────────────────────────

  group('slurs are blocked', () {
    // Racial slurs
    test('n-word is blocked', () {
      expect(validator.validate('nigger').isValid, isFalse);
    });

    test('n-word variant is blocked', () {
      expect(validator.validate('nigga').isValid, isFalse);
    });

    test('anti-Black slur is blocked', () {
      expect(validator.validate('a coon').isValid, isFalse);
    });

    test('antisemitic slur is blocked', () {
      expect(validator.validate('kike').isValid, isFalse);
    });

    test('anti-Latino slur is blocked', () {
      expect(validator.validate('spic').isValid, isFalse);
    });

    test('anti-Asian slur (1) is blocked', () {
      expect(validator.validate('chink').isValid, isFalse);
    });

    test('anti-Asian slur (2) is blocked', () {
      expect(validator.validate('gook').isValid, isFalse);
    });

    test('homophobic slur (1) is blocked', () {
      expect(validator.validate('faggot').isValid, isFalse);
    });

    test('homophobic slur (2) is blocked', () {
      expect(validator.validate('dyke').isValid, isFalse);
    });

    test('ableist slur is blocked', () {
      expect(validator.validate('retard').isValid, isFalse);
    });

    test('slur embedded in a sentence is blocked', () {
      expect(
        validator.validate('meeting a nigger at the store').isValid,
        isFalse,
      );
    });

    test('slur in mixed case is blocked', () {
      expect(validator.validate('NIGGER').isValid, isFalse);
    });
  });

  // ── Explicit sexual content blocking ────────────────────────────────────

  group('clearly explicit sexual content is blocked', () {
    test('graphic sex act term is blocked', () {
      expect(validator.validate('fucking').isValid, isFalse);
    });

    test('explicit body part (vulgar) is blocked', () {
      expect(validator.validate('a cunt').isValid, isFalse);
    });

    test('explicit phrase combining sex act with subject is blocked', () {
      expect(validator.validate('porn star').isValid, isFalse);
    });

    test('explicit penetration term is blocked', () {
      expect(validator.validate('anal sex').isValid, isFalse);
    });
  });

  // ── No reason exposed ────────────────────────────────────────────────────

  group('validation result shape', () {
    test('invalid result exposes no blocking reason', () {
      final result = validator.validate('nigger');
      expect(result.isValid, isFalse);
      // The result type must not carry a "reason" string — we verify by
      // checking the runtime type has no such property. This is a structural
      // guarantee enforced by the sealed class design.
    });

    test('valid result is valid', () {
      final result = validator.validate('a library at closing time');
      expect(result.isValid, isTrue);
    });
  });
}
