// ABOUTME: Unit tests for AtoCSequence — validates interval, looping, and prompt behaviour.
// ABOUTME: Confirms only the four allowed intervals are valid.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/atoc/atoc_sequence.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_controller.dart';
import 'package:hermit_prov_app/domain/drills/drill_session_state.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

void main() {
  const sequence = AtoCSequence();

  // 1. Default interval is 30 seconds.
  test('default interval is 30 seconds', () {
    const settings = AtoCSettings();
    expect(settings.interval, const Duration(seconds: 30));
  });

  // 2. Only allowed intervals are 15/30/45/60s.
  test('allowed intervals are 15, 30, 45, and 60 seconds', () {
    expect(AtoCSettings.allowedIntervals, [
      const Duration(seconds: 15),
      const Duration(seconds: 30),
      const Duration(seconds: 45),
      const Duration(seconds: 60),
    ]);
  });

  test('isValidInterval returns true for allowed values', () {
    for (final d in AtoCSettings.allowedIntervals) {
      expect(AtoCSequence.isValidInterval(d), isTrue,
          reason: 'Expected $d to be valid');
    }
  });

  test('isValidInterval returns false for disallowed value', () {
    expect(AtoCSequence.isValidInterval(const Duration(seconds: 20)), isFalse);
  });

  // 3. Prompt changes each interval (distinct segment ids).
  test('different rep indices produce distinct segment ids', () {
    final rep0 = sequence.buildRep(settings: const AtoCSettings());
    final rep1 = sequence.buildRep(settings: const AtoCSettings(), repIndex: 1);
    expect(rep0.first.id, isNot(rep1.first.id));
  });

  test('prompt is included in segment payload', () {
    final segs =
        sequence.buildRep(settings: const AtoCSettings(), prompt: 'dentist');
    expect(segs.first.promptPayload, 'dentist');
  });

  // 4. Flow loops until stopped.
  test('looping controller loops indefinitely', () {
    // Use 15s interval (shortest allowed); tick with 15s tick duration.
    final segs = sequence.buildRep(
      settings: const AtoCSettings(interval: Duration(seconds: 15)),
    );
    // 2 ticks = 2 loops.
    final ctrl = DrillSessionController(
      segments: segs,
      loops: true,
      tickDuration: const Duration(seconds: 15),
    )
      ..start()
      ..tick()
      ..tick();

    expect(ctrl.state.loops, 2);
    expect(ctrl.state.status, DrillSessionStatus.running);
  });
}
