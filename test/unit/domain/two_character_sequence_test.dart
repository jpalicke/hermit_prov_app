// ABOUTME: Unit tests for TwoCharacterSequence — verifies segment structure and looping.
// ABOUTME: Confirms regroup segment never carries a prompt.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/drills/two_character/two_character_sequence.dart';

void main() {
  const sequence = TwoCharacterSequence();
  const settings = TwoCharacterScenesSettings();

  // 1. Two-Character sequence: prompt → scene → regroup loop.
  test('buildRep returns scene then regroup segment', () {
    final segs = sequence.buildRep(settings: settings);

    expect(segs.length, 2);
    expect(segs[0].type, DrillSegmentType.speaking);
    expect(segs[1].type, DrillSegmentType.regroup);
  });

  test('scene segment carries the prompt', () {
    final segs = sequence.buildRep(settings: settings, prompt: 'a dentist');
    expect(segs[0].promptPayload, 'a dentist');
  });

  test('regroup segment never carries a prompt', () {
    final segs = sequence.buildRep(settings: settings, prompt: 'a dentist');
    expect(segs[1].promptPayload, isNull);
  });

  test('scene duration matches settings', () {
    final segs = sequence.buildRep(settings: settings);
    expect(segs[0].duration, settings.sceneDuration);
  });

  test('regroup duration matches settings', () {
    final segs = sequence.buildRep(settings: settings);
    expect(segs[1].duration, settings.regroupDuration);
  });

  // 2. Prompt regenerates after regroup (distinct segment ids per rep).
  test('different rep indices produce distinct segment ids', () {
    final rep0 = sequence.buildRep(settings: settings, repIndex: 0);
    final rep1 = sequence.buildRep(settings: settings, repIndex: 1);
    expect(rep0[0].id, isNot(rep1[0].id));
  });

  test('looping controller restarts after final regroup segment', () {
    final segs = sequence.buildRep(
      settings: const TwoCharacterScenesSettings(
        sceneDuration: Duration(seconds: 3),
        regroupDuration: Duration(seconds: 2),
      ),
    );
    final ctrl = DrillSessionController(segments: segs, loops: true);
    ctrl.start();

    for (var i = 0; i < 5; i++) {
      ctrl.tick();
    }

    expect(ctrl.state.loops, 1);
    expect(ctrl.state.status, DrillSessionStatus.running);
  });
}
