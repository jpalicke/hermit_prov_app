// ABOUTME: Widget tests for the expanded Tools screen with four menu items.
// ABOUTME: Verifies all four tools are listed and navigation to Prompt Generator works.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';
import 'package:hermit_prov_app/features/tools/prompt_generator_screen.dart';

Widget _wrapWithServices(Widget child) {
  return AppServices(
    promptRepository: InMemoryPromptRepository(),
    drillSettingsRepository: InMemoryDrillSettingsRepository(),
    practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
    journalRepository: InMemoryJournalRepository(),
    appPreferencesRepository: InMemoryAppPreferencesRepository(),
    ttsService: FakeTtsService(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('Tools screen items', () {
    testWidgets('shows all four tools', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const ToolsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Prompt Generator'), findsOneWidget);
      expect(find.text('Custom Prompts'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Emotion Wheel'), findsOneWidget);
    });

    testWidgets('Prompt Generator is reachable from Tools screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const ToolsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Prompt Generator'));
      await tester.pumpAndSettle();

      expect(find.byType(PromptGeneratorScreen), findsOneWidget);
    });
  });
}
