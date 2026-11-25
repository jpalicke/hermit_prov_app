// ABOUTME: Unit tests for DrillSegment value equality and copyWith.
// ABOUTME: Sequences and session state compare segments by value, so every field must count.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';

void main() {
  const base = DrillSegment(
    id: 'speaking_0',
    type: DrillSegmentType.speaking,
    duration: Duration(seconds: 30),
    promptPayload: 'A kite',
    label: 'Speak',
  );

  test('segments with the same fields are equal and hash alike', () {
    final copy = base.copyWith();
    expect(copy, base);
    expect(copy.hashCode, base.hashCode);
  });

  test('a difference in any single field makes segments unequal', () {
    final variants = {
      'id': base.copyWith(id: 'speaking_1'),
      'type': base.copyWith(type: DrillSegmentType.regroup),
      'duration': base.copyWith(duration: const Duration(seconds: 31)),
      'promptPayload': base.copyWith(promptPayload: 'A kettle'),
      'label': base.copyWith(label: 'Regroup'),
    };
    for (final MapEntry(:key, :value) in variants.entries) {
      expect(value, isNot(base), reason: key);
    }
  });
}
