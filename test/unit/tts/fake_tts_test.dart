// ABOUTME: Unit tests for FakeTtsService — verifies capture of spoken text and stop calls.
// ABOUTME: All tests are pure Dart, no Flutter imports needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';

void main() {
  group('FakeTtsService', () {
    test('captures spoken text in order', () async {
      final tts = FakeTtsService();

      await tts.speak('hello');
      await tts.speak('world');

      expect(tts.spoken, ['hello', 'world']);
    });

    test('stop increments stopCount', () async {
      final tts = FakeTtsService();

      await tts.stop();
      await tts.stop();

      expect(tts.stopCount, 2);
    });

    test('stop does not clear spoken list', () async {
      final tts = FakeTtsService();
      await tts.speak('hello');
      await tts.stop();

      expect(tts.spoken, ['hello']);
    });

    test('isEnabled returns true', () {
      final tts = FakeTtsService();
      expect(tts.isEnabled, isTrue);
    });

    test('getAvailableVoices returns empty list', () async {
      final tts = FakeTtsService();
      expect(await tts.getAvailableVoices(), isEmpty);
    });
  });
}
