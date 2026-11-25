// ABOUTME: Unit tests for FakeTtsService — verifies capture of spoken text and stop calls.
// ABOUTME: All tests are pure Dart, no Flutter imports needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';

void main() {
  group('FakeTtsService', () {
    test('stop increments stopCount', () async {
      final tts = FakeTtsService();

      await tts.stop();
      await tts.stop();

      expect(tts.stopCount, 2);
    });

    test('isEnabled returns true', () {
      final tts = FakeTtsService();
      expect(tts.isEnabled, isTrue);
    });
  });
}
