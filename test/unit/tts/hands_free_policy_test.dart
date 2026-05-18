// ABOUTME: Unit tests for HandsFreeAnnouncementPolicy — covers all announcement rules.
// ABOUTME: Uses FakeTtsService to capture spoken output without real TTS.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_segment.dart';
import 'package:hermit_prov_app/domain/tts/hands_free_announcement_policy.dart';

DrillSegment _seg({
  String id = 'seg_0',
  DrillSegmentType type = DrillSegmentType.speaking,
  Duration duration = const Duration(seconds: 60),
  String? promptPayload,
  String? label,
}) =>
    DrillSegment(
      id: id,
      type: type,
      duration: duration,
      promptPayload: promptPayload,
      label: label,
    );

void main() {
  late FakeTtsService tts;
  late HandsFreeAnnouncementPolicy policy;

  setUp(() {
    tts = FakeTtsService();
    policy = HandsFreeAnnouncementPolicy(tts);
  });

  group('onSegmentStart', () {
    test('speaks prompt text for non-regroup segment with promptPayload',
        () async {
      await policy.onSegmentStart(
        _seg(promptPayload: 'fire hydrant'),
      );
      expect(tts.spoken, ['fire hydrant']);
    });

    test('regroup segment is silent', () async {
      await policy.onSegmentStart(
        _seg(type: DrillSegmentType.regroup),
      );
      expect(tts.spoken, isEmpty);
    });

    test('non-regroup segment without prompt is silent on start', () async {
      await policy.onSegmentStart(_seg());
      expect(tts.spoken, isEmpty);
    });

    test('paused state suppresses start announcement', () async {
      await policy.onSegmentStart(
        _seg(promptPayload: 'bicycle'),
        paused: true,
      );
      expect(tts.spoken, isEmpty);
    });

    test(
        'Character Creation first-pass speaks "Character N: prompt" '
        'when label is "Character N"', () async {
      await policy.onSegmentStart(
        _seg(
          id: 'first_1',
          label: 'Character 1',
          promptPayload: 'red shoes',
        ),
      );
      expect(tts.spoken, ['Character 1: red shoes']);
    });

    test(
        'Character Creation first-pass with no prompt speaks only "Character N"',
        () async {
      await policy.onSegmentStart(
        _seg(
          id: 'first_2',
          label: 'Character 2',
        ),
      );
      expect(tts.spoken, ['Character 2']);
    });

    test(
        'Character Creation return-pass speaks "Character N" based on label',
        () async {
      await policy.onSegmentStart(
        _seg(
          id: 'return_3',
          label: 'Return to Character 3',
        ),
      );
      expect(tts.spoken, ['Character 3']);
    });

    test('paused suppresses Character Creation announcement', () async {
      await policy.onSegmentStart(
        _seg(id: 'first_1', label: 'Character 1', promptPayload: 'hat'),
        paused: true,
      );
      expect(tts.spoken, isEmpty);
    });
  });

  group('onTick — timer announcements', () {
    test('no announcements for segment exactly 30 seconds', () async {
      final seg = _seg(duration: const Duration(seconds: 30));
      await policy.onTick(seg, const Duration(seconds: 30));
      await policy.onTick(seg, const Duration(seconds: 10));
      await policy.onTick(seg, Duration.zero);
      expect(tts.spoken, isEmpty);
    });

    test('announces at 30 s, 10 s, 0 s for segments longer than 30 s',
        () async {
      final seg = _seg(duration: const Duration(seconds: 60));
      await policy.onTick(seg, const Duration(seconds: 30));
      await policy.onTick(seg, const Duration(seconds: 10));
      await policy.onTick(seg, Duration.zero);
      expect(tts.spoken, ['30 seconds', '10 seconds', 'time']);
    });

    test('does not fire at other tick values', () async {
      final seg = _seg(duration: const Duration(seconds: 60));
      await policy.onTick(seg, const Duration(seconds: 45));
      await policy.onTick(seg, const Duration(seconds: 20));
      expect(tts.spoken, isEmpty);
    });

    test('regroup is silent for timer ticks even on long segments', () async {
      final seg = _seg(
        type: DrillSegmentType.regroup,
        duration: const Duration(seconds: 60),
      );
      await policy.onTick(seg, const Duration(seconds: 30));
      expect(tts.spoken, isEmpty);
    });

    test('paused suppresses timer announcements', () async {
      final seg = _seg(duration: const Duration(seconds: 60));
      await policy.onTick(seg, const Duration(seconds: 30), paused: true);
      expect(tts.spoken, isEmpty);
    });

    test('AtoC 30 s prompt segment reads prompt but has no timer announcements',
        () async {
      final seg = _seg(
        duration: const Duration(seconds: 30),
        promptPayload: 'bicycle',
      );
      // Simulate start then ticks.
      await policy.onSegmentStart(seg);
      await policy.onTick(seg, const Duration(seconds: 30));
      await policy.onTick(seg, const Duration(seconds: 10));
      await policy.onTick(seg, Duration.zero);
      // Only the start announcement; no timer cues.
      expect(tts.spoken, ['bicycle']);
    });
  });
}
