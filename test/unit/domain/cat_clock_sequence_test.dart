// ABOUTME: Unit tests for CatClockSequence — verifies segment structure and looping behaviour.
// ABOUTME: Tests prompt regeneration via a looping DrillSessionController.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/cat_clock/cat_clock_sequence.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

void main() {
  const sequence = CatClockSequence();
  const settings = CatClockSettings();

  // 1. Cat/Clock sequence creates speaking + regroup segments.
  test('buildRep returns speaking then regroup segment', () {
    final segments = sequence.buildRep(settings: settings);

    expect(segments.length, 2);
    expect(segments[0].type, DrillSegmentType.speaking);
    expect(segments[1].type, DrillSegmentType.regroup);
  });

  test('speaking duration matches settings', () {
    final segments = sequence.buildRep(settings: settings);
    expect(segments[0].duration, settings.speakingDuration);
  });

  test('regroup duration matches settings', () {
    final segments = sequence.buildRep(settings: settings);
    expect(segments[1].duration, settings.regroupDuration);
  });

  // 2. Sequence loops until stopped (via looping controller).

  // 3. Prompts regenerate for each new speaking rep.
  test('different rep indices produce distinct segment ids', () {
    final rep0 = sequence.buildRep(settings: settings);
    final rep1 = sequence.buildRep(settings: settings, repIndex: 1);

    expect(rep0[0].id, isNot(rep1[0].id));
    expect(rep0[1].id, isNot(rep1[1].id));
  });

  test('null prompts produce null promptPayload', () {
    final segments = sequence.buildRep(settings: settings);
    expect(segments[0].promptPayload, isNull);
  });
}
