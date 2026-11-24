// ABOUTME: Regression tests for looping drills: a fresh suggestion every rep, full session time logged,
// ABOUTME: and hands-free announcing each rep's suggestion. Covers A-to-C, Two-Character, Cat/Clock, Five Line.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/features/drills/atoc/atoc_session_screen.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_session_screen.dart';
import 'package:hermit_prov_app/features/drills/five_line/five_line_session_screen.dart';
import 'package:hermit_prov_app/features/drills/two_character/two_character_session_screen.dart';

import 'sequenced_prompt_repository.dart';

const _oneCategory = [PromptCategory.objects];

Widget _host(Widget screen) =>
    AppServices.withInMemory(child: MaterialApp(home: screen));

/// Advances the session clock one second at a time, as the real ticker does.
Future<void> _advance(WidgetTester tester, int seconds) async {
  for (var i = 0; i < seconds; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  // Let any prompt load triggered by the last tick finish and rebuild.
  await tester.pump();
  await tester.pump();
}

Future<void> _start(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.tap(find.byKey(const Key('start_button')));
  await tester.pump();
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  group('A-to-C', () {
    Widget screen({
      InMemoryPracticeHistoryRepository? history,
      FakeTtsService? tts,
    }) =>
        AtoCSessionScreen(
          settings: AtoCSettings(
            interval: const Duration(seconds: 15),
            promptCategories: _oneCategory,
            handsFreeModeEnabled: tts != null,
          ),
          promptRepository: SequencedPromptRepository(),
          historyRepository: history,
          ttsService: tts,
          onSessionEnd: () {},
        );

    testWidgets('shows a new suggestion on every rep', (tester) async {
      await tester.pumpWidget(_host(screen()));
      await _start(tester);
      expect(_text(tester, 'atoc_prompt'), 'Prompt 1');

      await _advance(tester, 15);
      expect(_text(tester, 'atoc_prompt'), 'Prompt 2');

      await _advance(tester, 15);
      expect(_text(tester, 'atoc_prompt'), 'Prompt 3');

      await _advance(tester, 15);
      expect(_text(tester, 'atoc_prompt'), 'Prompt 4');
    });

    testWidgets('logs the whole session time across reps', (tester) async {
      final history = InMemoryPracticeHistoryRepository();
      await tester.pumpWidget(_host(screen(history: history)));
      await _start(tester);

      await _advance(tester, 50);
      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pump();

      final sessions = await history.getSessions();
      expect(sessions, hasLength(1));
      expect(sessions.single.duration, const Duration(seconds: 50));
    });

    testWidgets("hands-free announces each rep's suggestion", (tester) async {
      final tts = FakeTtsService();
      await tester.pumpWidget(_host(screen(tts: tts)));
      // Hands-free auto-starts.
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await _advance(tester, 30);

      expect(tts.spoken, containsAllInOrder(['Prompt 1', 'Prompt 2', 'Prompt 3']));
      expect(tts.spoken.where((s) => s.startsWith('Prompt')), hasLength(3));
    });
  });

  group('Two-Character Scenes', () {
    Widget screen({InMemoryPracticeHistoryRepository? history}) =>
        TwoCharacterSessionScreen(
          settings: const TwoCharacterScenesSettings(
            sceneDuration: Duration(seconds: 20),
            regroupDuration: Duration(seconds: 10),
            promptCategories: _oneCategory,
          ),
          promptRepository: SequencedPromptRepository(),
          historyRepository: history,
          onSessionEnd: () {},
        );

    testWidgets('shows a new suggestion on every rep', (tester) async {
      await tester.pumpWidget(_host(screen()));
      await _start(tester);
      expect(_text(tester, 'two_char_prompt'), 'Prompt 1');

      await _advance(tester, 30);
      expect(_text(tester, 'two_char_prompt'), 'Prompt 2');

      await _advance(tester, 30);
      expect(_text(tester, 'two_char_prompt'), 'Prompt 3');
    });

    testWidgets('logs the whole session time across reps', (tester) async {
      final history = InMemoryPracticeHistoryRepository();
      await tester.pumpWidget(_host(screen(history: history)));
      await _start(tester);

      await _advance(tester, 70);
      await tester.tap(find.byKey(const Key('stop_end_button')));
      await tester.pump();

      final sessions = await history.getSessions();
      expect(sessions.single.duration, const Duration(seconds: 70));
    });
  });

  group('Cat/Clock', () {
    testWidgets('shows new words on every rep without tapping New Words',
        (tester) async {
      await tester.pumpWidget(
        _host(
          CatClockSessionScreen(
            settings: const CatClockSettings(
              speakingDuration: Duration(seconds: 20),
              regroupDuration: Duration(seconds: 10),
            ),
            promptRepository: SequencedPromptRepository(),
            onSessionEnd: () {},
          ),
        ),
      );
      await _start(tester);
      expect(_text(tester, 'cat_clock_prompt1'), 'Prompt 1');
      expect(_text(tester, 'cat_clock_prompt2'), 'Prompt 2');

      await _advance(tester, 30);
      expect(_text(tester, 'cat_clock_prompt1'), 'Prompt 3');
      expect(_text(tester, 'cat_clock_prompt2'), 'Prompt 4');

      await _advance(tester, 30);
      expect(_text(tester, 'cat_clock_prompt1'), 'Prompt 5');
      expect(_text(tester, 'cat_clock_prompt2'), 'Prompt 6');
    });
  });

  group('Five Line Scenes auto-advance', () {
    Widget screen({FakeTtsService? tts}) => FiveLineSessionScreen(
          settings: FiveLineGameSettings(
            autoAdvance: true,
            autoAdvanceInterval: const Duration(seconds: 30),
            promptCategories: _oneCategory,
            handsFreeModeEnabled: tts != null,
          ),
          promptRepository: SequencedPromptRepository(),
          ttsService: tts,
          onSessionEnd: () {},
        );

    testWidgets('keeps the first suggestion until the first rep ends',
        (tester) async {
      await tester.pumpWidget(_host(screen()));
      await _start(tester);
      expect(_text(tester, 'five_line_prompt'), 'Prompt 1');

      await _advance(tester, 30);
      expect(_text(tester, 'five_line_prompt'), 'Prompt 2');
    });

    testWidgets("hands-free announces each rep's suggestion", (tester) async {
      final tts = FakeTtsService();
      await tester.pumpWidget(_host(screen(tts: tts)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await _advance(tester, 60);

      final prompts = tts.spoken.where((s) => s.startsWith('Prompt')).toList();
      expect(prompts, ['Prompt 1', 'Prompt 2', 'Prompt 3']);
    });
  });
}
