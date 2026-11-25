// ABOUTME: Unit tests for CharacterCreationCycleBuilder — validates cycle order, durations, constraints.
// ABOUTME: Tests pass-type labelling, total duration calculation, and validation logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/character_creation/character_creation_cycle.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

void main() {
  const builder = CharacterCreationCycleBuilder();

  // ── 2. 5-character cycle has correct segment order ─────────────────────────
  test('5-character cycle has correct segment order', () {
    const settings = CharacterCreationSettings(characterCount: 5);
    final segs = builder.buildCycle(settings);

    expect(segs.length, 10);
    expect(segs[0].id, 'first_1');
    expect(segs[4].id, 'first_5');
    expect(segs[5].id, 'return_1');
    expect(segs[9].id, 'return_5');
  });

  // ── 3. Total duration calculation is correct ──────────────────────────────
  test('total duration = characters × 2 × segment duration', () {
    const settings = CharacterCreationSettings(
      characterCount: 3,
      segmentDuration: Duration(seconds: 90),
    );
    final total = builder.totalDuration(settings);
    expect(total, const Duration(seconds: 90 * 3 * 2));
  });

  // ── 5. Invalid character counts are rejected / clamped ────────────────────
  test('isValidCharacterCount returns true for 2–5', () {
    for (var c = 2; c <= 5; c++) {
      expect(CharacterCreationCycleBuilder.isValidCharacterCount(c), isTrue);
    }
  });

  test('clampCharacterCount clamps below min to 2', () {
    expect(CharacterCreationCycleBuilder.clampCharacterCount(0), 2);
    expect(CharacterCreationCycleBuilder.clampCharacterCount(1), 2);
  });

  test('clampCharacterCount clamps above max to 5', () {
    expect(CharacterCreationCycleBuilder.clampCharacterCount(6), 5);
    expect(CharacterCreationCycleBuilder.clampCharacterCount(99), 5);
  });

  // ── 6. Return-pass segments are correctly labelled ────────────────────────

  test('return-pass label contains "Return to Character N"', () {
    const settings = CharacterCreationSettings();
    final segs = builder.buildCycle(settings);

    expect(segs[2].label, contains('Return to Character 1'));
    expect(segs[3].label, contains('Return to Character 2'));
  });
}
